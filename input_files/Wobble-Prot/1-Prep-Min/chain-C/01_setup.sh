#!/bin/bash -e
Dir=`pwd`

grom=gmx_mpi
chain=C
sys=9JGM-${chain}-P
start=9JGM.pdb
pdbid=9JGM

echo "PDBFixer ..."
pdbfixer --pdbid=$pdbid --add-atoms=heavy --keep-heterogens=all --output=${pdbid}_fixed.pdb
awk -v chain=$chain '$5==chain {print $0}' ${pdbid}_fixed.pdb > ${pdbid}_fixed_${chain}_allmg.pdb

# Exclude all Mg2+ except the one in the binding pocket using the residue number
mg=203
awk -v mg=$mg '!/^HETATM/ || !/MG/ || $6 == mg {print $0}' ${pdbid}_fixed_${chain}_allmg.pdb > ${pdbid}_fixed_${chain}.pdb

# Convert Mn atom to MG
sed -i 's/MN/MG/g' ${pdbid}_fixed_${chain}.pdb
sed -i 's/Mn/Mg/g' ${pdbid}_fixed_${chain}.pdb

# This needs to be modified manually to account for the atom numbering of the correct chain    
echo "Remove P,O1P and O2P from first residue..."
sed -i '/ATOM      1  P /d' ${pdbid}_fixed_${chain}.pdb
sed -i '/ATOM      2  OP1 /d' ${pdbid}_fixed_${chain}.pdb
sed -i '/ATOM      3  OP2 /d' ${pdbid}_fixed_${chain}.pdb
sed -i 's/MG    MG C/MG    MG A/g' ${pdbid}_fixed_${chain}.pdb


python3 convert_pdb_cph.py ${pdbid}_fixed_${chain}.pdb $start true true
#### MANUAL PART ####

# Correct OH3 cap numbering and order
# Correct Mg numbering
# Change to protonated state (AR1) for res A276 (A92 in normal PDB numbering)

###### MANUAL PART ######
# Generate topology and gro files
$grom pdb2gmx -f $start -o $sys.gro -p $sys.top -water select -ignh <<EOF 
1
6
EOF
# If it generates an error related to the O3' bond, then it's an order issue of the pdb
# The OH3 cap should be placed before the last nucleobase (i.e. CR0 316 in this case)
# Manually reorder and adjust the residue numbering by hand
# Also check the residue numbering of the MG

# Change from MG to mMG
sed -i 's/MG      MG /mMg    mMg /g' ${sys}.gro
sed -i 's/MG/mMg/g' ${sys}_Ion_chain_A.itp


# Small bug. The first include is not in the right position.
#./correct_top.py ${sys}.top ${sys}.top

# Correct topology from MG to mMG for the crystallographic ions
#sed -i 's/ MG /mMg /g' ${sys}.top
# Generate box and solvate. The dodecahedron is the most cost effective simulation box to solvate for non-membrane systems.
# The value 1.5 found in other simulations might be too big of a distance to the box limit as the periodic image won't be close to the original molecule.
# Still, a quick assessment of the periodic image is good practice, to assess if the original molecule and its periodic image are not "seeing" each other within the non bonded cutoff (1.4)

$grom editconf -f $sys.gro -o box.gro -bt dodecahedron -d 1.2 -resnr 1

# Solvate box using opc watermodel (4 point charge)
$grom solvate -cp box.gro -cs opc.gro -o solv.gro -p $sys.top

n_water=$(awk '/^SOL/ { print $2 }' ${sys}.top)
echo "Total water: $n_water"

# 50 mM KCl + 5 mM Mg + 1 mM Mn (maybe not included)

# Negative charge of RNA = number of phosphates
n_rna=$(awk '/^\s*[0-9]+POX\s+P\s*[0-9]/ { count++ } END { print count }' solv.gro)
echo "N Phosphates (RNA charge): $n_rna"

n_mg_init=$(awk '/^\s*[0-9]+mMg/ { count++ } END { print count }' solv.gro)
echo "Initial MG: $n_mg_init"

n_prot_positive=$(awk '/^\s*[0-9]+[A-C]R1\s+N1\s*[0-9]/ { count++ } END { print count }' solv.gro)
echo "Number of positively charged protonated residues: $n_prot_positive"
# Compute number of ions required
# 1) Neutralize RNA with Mg²⁺ and K⁺ with 3 to 1 ratio and keeping the structural Mg²⁺ in the pocket 
# (paper ion competition: https://doi.org/10.1016%2Fj.bpj.2019.08.007)
# exp conditions: https://pmc.ncbi.nlm.nih.gov/articles/PMC12153347/#SEC2

# Actually in this case, divalent ions will not be added for simplicity sake
# The chosen FF for the crystallographic Mg's is microMg (mMg)
# 2*n_mg + n_na = n_rna
# 7*n_na = n_rna
n_mg=0 #$((3*n_rna/7))
echo "Total MG on RNA: $n_mg"
n_k=$((n_rna-2*n_mg_init))
echo "Total K on RNA: $n_k"


# 2) Add ions in bulk to target concentrations 5 mM MgCl₂ and 50 mM KCl
# n_water_bulk ~ 0.86*n_water (estimated from [Cl] in previous iterations)
#n_mg_bulk=$(python -c "print(round(0.01/55.5*0.86*$n_water))")
#echo "Total MG in bulk: $n_mg_bulk"
n_k_bulk=$(python -c "print(round(0.05/55.5*0.86*$n_water))")
echo "Total K in bulk: $n_k_bulk"
n_cl=$((n_k_bulk))
echo "Total Cl in bulk: $n_cl"

# 3) To be added
n_mg_added=$((n_mg+n_mg_bulk-n_mg_init))
n_k_added=$((n_k+n_k_bulk))
n_cl_added=$((n_cl+n_prot_positive))
echo "Genion will add: $n_mg_added MG, $n_k_added K, $n_cl_added CL"


if [ ! -f min1.mdp ];then

cat > min1.mdp << EOF
; LINES STARTING WITH ';' ARE COMMENTS
title           = Minimization $sys   ; Title of run

; The following lines tell the program the standard locations where to find certain files
cpp             = /lib/cpp      ; Preprocessor
;include        = -I../top      ; Directories to include in the topology format

; Define can be used to control processes (POSITION RESTRAINTS)
define          = -DPOSRES -DPOSRES_WATER

; Parameters describing what to do, when to stop and what to save
integrator      = steep         ; Algorithm (steep = steepest descent minimization)
;emtol           = 1.0           ; Stop minimization when the maximum force < 1.0 kJ mol-1 nm-1
nsteps          = 50000         ; Maximum number of (minimization) steps to perform
nstenergy       = 50            ; Write energies to disk every nstenergy steps
nstxtcout       = 50            ; Write coordinates to disk every nstxtcout steps
nstvout         = 50
nstlog          = 50
xtc_grps        = System        ; Which coordinate group(s) to write to disk
energygrps      = System        ; Which energy group(s) to write to disk

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions

cutoff-scheme=Verlet
nstlist         = 5             ; Frequency to update the neighbor list and long range forces
ns_type         = grid          ; Method to determine neighbor list (simple, grid)
constraints     = none          ; Bond types to replace by constraints

;treatment of electrostatic interactions
coulombtype = PME 

;treatment of van der waals interactions
rvdw = 1.0 
rlist = 1.0 
rcoulomb = 1.0 

;fourierspacing = 0.12 
; Periodic boudary conditions in all the direcbctions 
pbc                      = xyz
EOF
fi

# If the charge is non-neutral, ions would be added to achieve neutrality. Ionic strength effects also require ions to be added at a certain concentration e.g. 0.1M
$grom grompp -f min1.mdp -c solv.gro -r solv.gro -p $sys.top -o ion1.tpr -maxwarn 100
$grom genion -s ion1.tpr -p $sys.top -o solv_ion.gro -pname K -pq 1 -np $n_k_added -nname CL -nq -1 -nn $n_cl_added <<EOF
SOL
EOF
#$grom grompp -f min1.mdp -c ion1.gro -r ion1.gro -p $sys.top -o ion2.tpr -maxwarn 100
#$grom genion -s ion2.tpr -p $sys.top -o solv_ion.gro -pname MG -pq 2 -np $n_mg_added  <<EOF
#SOL
#EOF

# AR0276 is the A92 (or A114 according to the slide)
# In this system it will be deprotonated
# With the system setup finished, we need to minimize the system prior to "turning on" both the thermostat and barostat

