#!/bin/bash

#SBATCH -p boost_usr_prod #lrd_all_serial
#SBATCH --time 10:00:00     # format: HH:MM:SS
#SBATCH -N 1                # 1 node
#SBATCH --ntasks-per-node=16 # 4 tasks out of 32
#SBATCH --job-name=minimization

Dir=`pwd`

grom=gmx_mpi
sys=9JGM-A

# First we need to define the minimization parameters to minimize the potential energy of the system. Typically it uses a steepest descent integrator,
# with a user defined timestep, however a lbfgs integrator can be used to search for other energy minima. Both these methods can be coupled to improve the protocol 

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
; Periodic boudary conditions in all the directions 
pbc                      = xyz
EOF
fi

if [ ! -f min2.mdp ];then

cat > min2.mdp << EOF
; LINES STARTING WITH ';' ARE COMMENTS
title           = Minimization deprot_adenosine   ; Title of run

; The following lines tell the program the standard locations where to find certain files
cpp             = /lib/cpp      ; Preprocessor
;include        = -I../top      ; Directories to include in the topology format

; Define can be used to control processes (POSITION RESTRAINTS)
define          = -DFLEXIBLE    ; lbfgs integrator does not use constraints. As such, -DFLEXIBLE is required to turn off SETTLE constraints on water molecules

; Parameters describing what to do, when to stop and what to save
integrator      = l-bfgs         ; Algorithm (steep = steepest descent minimization)
emtol           = 0.0           ; Stop minimization when the maximum force < 1.0 kJ mol-1 nm-1
emstep          =  0.001        ; Step of energy minimization
nsteps          = 50000         ; Maximum number of (minimization) steps to perform
nstenergy       = 50            ; Write energies to disk every nstenergy steps
nstxtcout       = 50            ; Write coordinates to disk every nstxtcout steps
nstvout         = 50
nstlog          = 50
xtc_grps        = System        ; Which coordinate group(s) to write to disk
energygrps      = System        ; Which energy group(s) to write to disk

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions

cutoff-scheme = Verlet
nstlist         = 5             ; Frequency to update the neighbor list and long range forces
ns_type         = grid          ; Method to determine neighbor list (simple, grid)

;treatment of electrostatic interactions
coulombtype = PME 

;treatment of van der waals interactions
vdwtype = PME
rvdw = 1.0 
rlist = 1.0 
rcoulomb = 1.0 

;fourierspacing = 0.12 
; Periodic boudary conditions in all the directions 
pbc                      = xyz

; Constraints Parameters
constraints =  none
EOF
fi

if [ ! -f min3.mdp ];then

cat > min3.mdp << EOF
; LINES STARTING WITH ';' ARE COMMENTS
title           = Minimization deprot_adenosine   ; Title of run

; The following lines tell the program the standard locations where to find certain files
cpp             = /lib/cpp      ; Preprocessor
;include        = -I../top      ; Directories to include in the topology format

; Define can be used to control processes (POSITION RESTRAINTS)
;define          = -DFLEXIBLE    ; lbfgs integrator does not use constraints. As such, -DFLEXIBLE is required to turn off SETTLE constraints on water molecules

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

cutoff-scheme = Verlet
nstlist         = 5             ; Frequency to update the neighbor list and long range forces
ns_type         = grid          ; Method to determine neighbor list (simple, grid)

;treatment of electrostatic interactions
coulombtype = PME 

;treatment of van der waals interactions
rvdw = 1.0 
rlist = 1.0 
rcoulomb = 1.0 

;fourierspacing = 0.12 
; Periodic boudary conditions in all the directions 
pbc                      = xyz

; Constraints Parameters
constraint_algorithm=lincs
lincs_order         =  8
lincs-warnangle     =  90
constraints         =  all-bonds
EOF
fi
# Then we generate an index file to operate with the system atoms. If you add ions to your system, this step should be done afterward and reviewed.
# In this step, we only need System SOL RNA ,hence we delete redundant entries.

#$grom make_ndx -f solv_ion.gro -o index.ndx<<EOF
#del 1
#1|2|3|4|5|6
#name 22 RNA
#name 21 SOL
#del 1-20
#2
#name 3 Protein
#3
#name 4 Solute
#q
#EOF

# After generating the mdp and index files, we need to run grompp to generate the tpr file. The tpr is an extended topology file that has an atomic description of the system
# based on the molecular topology and the provided mdp parameters. Then we run the minimization.

$grom grompp -f min1.mdp -c solv_ion.gro -p $sys.top -o min1.tpr -r solv_ion.gro -maxwarn 100
$grom mdrun -v -s min1.tpr -o min1.trr -c min1.gro -e min1.edr -pin on -ntomp 16

# Then for the second step of minimization, where try to search for other possible minima around the minimum found in the previous step.
$grom grompp -f min2.mdp -c min1.gro -p $sys.top -o min2.tpr -r min1.gro -maxwarn 100
$grom mdrun -v -s min2.tpr -o min2.trr -c min2.gro -e min2.edr -pin on -ntomp 16

# A third step is required to re-minimize the structures with a constraint, since lbfgs without constraints on water molecules might induce weird geometries.
$grom grompp -f min3.mdp -c min2.gro -p $sys.top -o min3.tpr -r min2.gro -maxwarn 100
$grom mdrun -v -s min3.tpr -o min3.trr -c min3.gro -e min3.edr -pin on -ntomp 16

# We could add the ion step after this
## $grom genion -s min1.tpr -o solv_ion.gro -p $sys.top -pname NA -nname CL -neutral -conc 0.15

# solv_ion.gro should be minimized if generated and not solv.gro as next shown.


# Check for the periodic image
#$grom mindist -f min3.gro -pi -o per_img.out -s min3.tpr
