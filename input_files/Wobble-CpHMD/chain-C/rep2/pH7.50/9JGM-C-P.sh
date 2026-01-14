#!/bin/bash -e
#
#
# ==== SLURM part (resource manager part) ===== #
#   Modify the following options based on your job's needs.
#   Remember that better job specifications mean better usage of resources,
#   which then means less time waiting for your job to start.
#   So, please specify as many details as possible.
#   A description of each option is available next to it.
#   SLURM cheatsheet:
#
#     https://slurm.schedmd.com/pdfs/summary.pdf
#
#
# ---- Metadata configuration ----
#
#SBATCH --job-name=7.50_9JGM-C-P     # The name of your job, you'll se it in squeue.
#SBATCH --mail-type=NONE              # Mail events (NONE, BEGIN, END, FAIL, ALL). Sends you an email when the job begins, ends, or fails; you can combine options.
#SBATCH --mail-user=tfernand@sissa.it    # Where to send the mail
#
# ---- CPU resources configuration  ----  |  Clarifications at https://slurm.schedmd.com/mc_support.html
#
#SBATCH --account=Sis25_bussi
#SBATCH --nodes=1                   # Number of nodes
#SBATCH --ntasks=1                  # Number of MPI ranks (1 for MPI serial job)
#SBATCH --ntasks-per-node=1                 
#SBATCH --cpus-per-task=16  #2       # Number of threads per MPI rank (MAX: 2x32 cores on _partition_2, 2x20 cores on _partition_1)
#[optional] #SBATCH --ntasks-per-core=1          # How many tasks on each core (set to 1 to be sure that different tasks run on different cores on multi-threaded systems)
#
# ---- Other resources configuration (e.g. GPU) ----
#
#SBATCH --gres=gpu:1                       # Total number of GPUs for the job (MAX: 2 x number of nodes, only available on gpu1 and gpu2)
#SBATCH --gpus-per-node=1            # Number of GPUs per node (MAX: 2, only available on gpu1 and gpu2)
##SBATCH --gpus-per-task=1            # Number of GPUs per MPI rank (MAX: 2, only available on gpu1 and gpu2); to be used with --ntasks
#
# ---- Memory configuration ----
#
#SBATCH --mem=7900mb                 # Memory per node (MAX: 63500 on the new ones, 40000 on the old ones); incompatible with --mem-per-cpu.
#[optional] #SBATCH --mem-per-cpu=4000mb         # Memory per thread; incompatible with --mem
#
# ---- Partition, Walltime and Output ----
#
#[unconfig] #SBATCH --array=01-10    # Create a job array. Useful for multiple, similar jobs. To use, read this: https://slurm.schedmd.com/job_array.html
#SBATCH --partition=boost_usr_prod    # Partition (queue). Avail: regular1, regular2, long1, long2, wide1, wide2, gpu1, gpu2. Multiple partitions are possible.
##SBATCH --qos=boost_qos_dbg
#SBATCH --time=24:00:00              # Time limit hrs:min:sec
#SBATCH --output=%x.o%j              # Standard output log in TORQUE-style -- WARNING: %x requires a new enough SLURM. Use %j for regular jobs and %A-%a for array jobs
#SBATCH --error=%x.e%j               # Standard error  log in TORQUE-style -- WARNING: %x requires a new enough SLURM. Use %j for regular jobs and %A-%a for array jobs
#
# ==== End of SLURM part (resource manager part) ===== #
#
#
# ==== Modules part (load all the modules) ===== #
#   Load all the modules that you need for your job to execute.
#   Additionally, export all the custom variables that you need to export.
#   Example:
#
#     module load intel
#     export PATH=:/my/custom/path/:$PATH
#     export MAGMA_NUM_GPUS=2
#
#
module unload fftw
module unload gmp
#module load gromacs/2022.3--openmpi--4.1.4--gcc--11.3.0-cuda-11.8
module use /leonardo/pub/userexternal/olanguin/modules
module load gromacs/2023/2023.5-plumed-2.10b

export OMP_PLACES=threads
export GMX_GPU_DD_COMMS=true
export GMX_GPU_PME_PP_COMMS=true
export GMX_ENABLE_DIRECT_GPU_COMM=true
#export GMX_FORCE_UPDATE_DEFAULT_GPU=true
#export GMX_DISABLE_GPU_TIMING=true

# ==== End of Modules part (load all the modules) ===== #
#
#
# ==== Info part (say things) ===== #
#   DO NOT MODIFY. This part prints useful info on your output file.
#
NOW=06:48-Sat-29/Nov/2025
echo '------------------------------------------------------'
echo 'This job is allocated on '${SLURM_JOB_CPUS_PER_NODE}' cpu(s)'
echo 'Job is running on node(s): '
echo  ${SLURM_JOB_NODELIST}
echo '------------------------------------------------------'
echo 'WORKINFO:'
echo 'SLURM: job starting at           '${NOW}
echo 'SLURM: sbatch is running on      '${SLURM_SUBMIT_HOST}
echo 'SLURM: executing on cluster      '${SLURM_CLUSTER_NAME}
echo 'SLURM: executing on partition    '${SLURM_JOB_PARTITION}
echo 'SLURM: working directory is      '${SLURM_SUBMIT_DIR}
echo 'SLURM: current home directory is '$(getent passwd $SLURM_JOB_ACCOUNT | cut -d: -f6)
echo ""
echo 'JOBINFO:'
echo 'SLURM: job identifier is         '$SLURM_JOBID
echo 'SLURM: job name is               '$SLURM_JOB_NAME
echo ""
echo 'NODEINFO:'
echo 'SLURM: number of nodes is        '$SLURM_JOB_NUM_NODES
echo 'SLURM: number of cpus/node is    '$SLURM_JOB_CPUS_PER_NODE
echo 'SLURM: number of gpus/node is    '$SLURM_GPUS_PER_NODE
echo '------------------------------------------------------'
#
# ==== End of Info part (say things) ===== #
#

# Should not be necessary anymore with SLURM, as this is the default, but you never know...
cd $SLURM_SUBMIT_DIR


# ==== JOB COMMANDS ===== #
#   The part that actually executes all the operations you want to do.
#   Just fill this part as if it was a regular Bash script that you want to
#   run on your computer.
#   Example:
#
#     echo "Hello World! :)"
#     ./HelloWorld
#     echo "Executing post-analysis"
#     ./Analyze
#     mv analysis.txt ./results/
#
InitDate=`date`
# Finds current block
i=1
j=001

while [ -f 9JGM-C-P_${j}.occ ] ; do
        i=$((i+1))
        j=`printf "%03d\n" ${i}`
done
k=$((i-1))
l=`printf "%03d\n" ${k}`

# Info about the Job:
echo "Job executed in Machine $HOSTNAME" > $SLURM_SUBMIT_DIR/9JGM-C-P_${j}.blockinfo
echo "Job executed with $nCPU processors" >> $SLURM_SUBMIT_DIR/9JGM-C-P_${j}.blockinfo


# Copy important files for local directory; first gro is called 
mkdir -p /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/tfernand_CpHMD$$
 
echo "Job executed in DIR: /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/tfernand_CpHMD$$ " >> $SLURM_SUBMIT_DIR/9JGM-C-P_${j}.blockinfo

echo "" >> $SLURM_SUBMIT_DIR/9JGM-C-P_${j}.blockinfo
echo -e "Job started on: " >> $SLURM_SUBMIT_DIR/9JGM-C-P_${j}.blockinfo
date >> $SLURM_SUBMIT_DIR/9JGM-C-P_${j}.blockinfo
# Enter local directory
cd /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/tfernand_CpHMD$$

# Copy input files to local directory 
cp -rdf $SLURM_SUBMIT_DIR/*.itp .

if [ ${i} -eq 1 ]; then 
   echo $1 
   rsync -r $SLURM_SUBMIT_DIR/$1 9JGM-C-P_${j}.pHmdp
elif [[ ${plumedtype} == "grid" ]] ;then
   rsync -r $SLURM_SUBMIT_DIR/9JGM-C-P_${l}.gro ./
   #rsync -r $SLURM_SUBMIT_DIR/HILLS_${j} ./
   rsync -r $SLURM_SUBMIT_DIR/colvar ./
   rsync -r $SLURM_SUBMIT_DIR/GRIDS ./
   sed "s/GROin=.*/GROin=9JGM-C-P_${l}.gro/g" $SLURM_SUBMIT_DIR/$1 > 9JGM-C-P_${j}.pHmdp
elif [[ ${plumedtype} == "hills" ]] ;then
   rsync -r $SLURM_SUBMIT_DIR/9JGM-C-P_${l}.gro ./
   rsync -r $SLURM_SUBMIT_DIR/HILLS ./
   rsync -r $SLURM_SUBMIT_DIR/colvar ./
   sed "s/GROin=.*/GROin=9JGM-C-P_${l}.gro/g" $SLURM_SUBMIT_DIR/$1 > 9JGM-C-P_${j}.pHmdp
elif [[ ${plumedtype} == "static" ]] ;then
   rsync -r $SLURM_SUBMIT_DIR/9JGM-C-P_${l}.gro ./
   rsync -r $SLURM_SUBMIT_DIR/HILLS ./
   rsync -r $SLURM_SUBMIT_DIR/colvar ./
   sed "s/GROin=.*/GROin=9JGM-C-P_${l}.gro/g" $SLURM_SUBMIT_DIR/$1 > 9JGM-C-P_${j}.pHmdp
elif [[ ${plumedtype} == "generic" ]] ;then
   rsync -r $SLURM_SUBMIT_DIR/9JGM-C-P_${l}.gro ./
   rsync -r $SLURM_SUBMIT_DIR/colvar ./
   sed "s/GROin=.*/GROin=9JGM-C-P_${l}.gro/g" $SLURM_SUBMIT_DIR/$1 > 9JGM-C-P_${j}.pHmdp
else
   rsync -r $SLURM_SUBMIT_DIR/9JGM-C-P_${l}.gro ./
   sed "s/GROin=.*/GROin=9JGM-C-P_${l}.gro/g" $SLURM_SUBMIT_DIR/$1 > 9JGM-C-P_${j}.pHmdp
fi
Seg_tot_time=`awk -v n=10 '$2 ~ /^EffectiveSteps=/ {m=substr ($2,16); print (n*1000)/(m*0.002)}' 9JGM-C-P_${j}.pHmdp`

sed -i "s/InitCycle=.*/InitCycle=$(($Seg_tot_time*$k+1))/g" 9JGM-C-P_${j}.pHmdp
sed -i "s/EndCycle=.*/EndCycle=$(($Seg_tot_time*$i))/g"  9JGM-C-P_${j}.pHmdp

# line needed to mount /programs using autofs
#ls /programs/ >/dev/null 2>&1; sleep 2
#
CpHMDDIR=`egrep "CpHDIR="  9JGM-C-P_${j}.pHmdp 2>/dev/null| awk '{print substr($2,9,length($2)-9)}' 2>/dev/null`
rsync -r $CpHMDDIR/scripts/CpHMD.sh .

echo "starting to decompose mdp and fixgro"

## Decompose the mdp options from the run_CpHMD into an individual mdp ##
awk '/#mdp# / {print}' 9JGM-C-P_${j}.pHmdp | sed 's/#mdp# //g' > 9JGM-C-P.mdp

## Decompose the fixgro options from the run_CpHMD into an individual fixgro ##
awk '/#fixgro# / {print}' 9JGM-C-P_${j}.pHmdp | sed 's/#fixgro# //g' > 9JGM-C-P.fixgro
#
## Decompose the plumed options from the run_CpHMD into an individual plumed.dat ##
if [[ $plumedtype == "grid" ]] ;then
    awk '/#plumed# / {print}' 9JGM-C-P_${j}.pHmdp | sed 's/#plumed# //g' > 9JGM-C-P_plumed.dat
    sed -i "s/\&colvar_stride/1000/g" 9JGM-C-P_plumed.dat
    sed -i "s/\&grid_name/GRIDS/g" 9JGM-C-P_plumed.dat
    sed -i "s/\&hills/HILLS/g" 9JGM-C-P_plumed.dat
    sed -i "s/\&colvar_name/colvar/g" 9JGM-C-P_plumed.dat
fi

if [[ $plumedtype == "hills" ]] || [[ $plumedtype == "static" ]] ;then
    awk '/#plumed# / {print}' 9JGM-C-P_${j}.pHmdp | sed 's/#plumed# //g' > 9JGM-C-P_plumed.dat
    sed -i "s/\&colvar_stride/1000/g" 9JGM-C-P_plumed.dat
    sed -i "s/\&hills/HILLS/g" 9JGM-C-P_plumed.dat
    sed -i "s/\&colvar_name/colvar/g" 9JGM-C-P_plumed.dat
fi


if [[ $plumed -eq 1 ]]  || [[ $plumedtype == "generic" ]] ;then
    awk '/#plumed# / {print}' 9JGM-C-P_${j}.pHmdp | sed 's/#plumed# //g' > 9JGM-C-P_plumed.dat
    sed -i "s/\&colvar_stride/1000/g" 9JGM-C-P_plumed.dat
    sed -i "s/\&colvar_name/colvar/g" 9JGM-C-P_plumed.dat
fi

# Run Constant-pH MD segment:
#nice -n 19 /tmp/tfernand_CpHMD$$/CpHMD.sh  9JGM-C-P_${j}.pHmdp > 9JGM-C-P_${j}.err 2>&1 
nice -n 19 bash /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/tfernand_CpHMD$$/CpHMD.sh 9JGM-C-P_${j}.pHmdp > 9JGM-C-P_${j}.err 2>&1 

# Copy files and return to shared directory
rsync -r /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/tfernand_CpHMD$$/9JGM-C-P_${j}* $SLURM_SUBMIT_DIR
if [ ! -f $SLURM_SUBMIT_DIR/9JGM-C-P.sites ] ; then
rsync ./9JGM-C-P.sites $SLURM_SUBMIT_DIR/
fi
if [ -f /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/tfernand_CpHMD$$/colvar ] && [ -f /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/tfernand_CpHMD$$/HILLS ] && [[ $plumedtype != "grid" ]]  ; then
rsync -r ./colvar $SLURM_SUBMIT_DIR
rsync -r ./HILLS $SLURM_SUBMIT_DIR
fi
#
if [ -f /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/tfernand_CpHMD$$/colvar ] && [[ $plumedtype == "grid" ]]  ; then
rsync -r ./colvar $SLURM_SUBMIT_DIR
mv HILLS_curr_seg HILLS_${j}
rsync -r ./HILLS_${j} $SLURM_SUBMIT_DIR
rsync -r ./GRIDS $SLURM_SUBMIT_DIR 
fi

if [ -f /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/tfernand_CpHMD$$/colvar ] && [[ $plumedtype == "static" ]]  ; then
    if [ -f /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/colvar ] ; then    
        rsync -r ./colvar $SLURM_SUBMIT_DIR/colvar_${j}
        cat colvar_${j} colvar > tmp_colvar
        mv tmp_colvar colvar
    else
        rsync -r ./colvar $SLURM_SUBMIT_DIR/colvar_${j}
        rsync -r ./colvar $SLURM_SUBMIT_DIR/colvar
    fi
fi
#
if [ -f /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/tfernand_CpHMD$$/colvar ] && [[ $plumedtype == "generic" ]]  ; then
rsync -r ./colvar $SLURM_SUBMIT_DIR
fi

if (for f in 9JGM-C-P_${j}*; do diff $f $SLURM_SUBMIT_DIR/$f; done); then
gzip -9 9JGM-C-P_${j}.{err,log,tpr}
cd $SLURM_SUBMIT_DIR
rm -rf /leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-C/09_CpH-restr/wobble/rep2/pH7.50/tfernand_CpHMD$$
gzip -9 9JGM-C-P_${j}.{err,log,tpr}
else
echo "Error in file copy... please check local files" >> $SLURM_SUBMIT_DIR/9JGM-C-P_${j}.blockinfo
exit 1
fi
#
echo "" >> $SLURM_SUBMIT_DIR/9JGM-C-P_${j}.blockinfo
echo -e "Job finished on: " >> $SLURM_SUBMIT_DIR/9JGM-C-P_${j}.blockinfo
date >> $SLURM_SUBMIT_DIR/9JGM-C-P_${j}.blockinfo
#
# Launch next job before exiting:
if [ ${i} -lt $Segments ] # usually 1 segment == 1 ns
then
    cd $SLURM_SUBMIT_DIR; ./slurm_CpHMetaD_leo.sh $1
fi
# ==== END OF JOB COMMANDS ===== #


# Wait for processes, if any.
echo "Waiting for all the processes to finish..."
wait

