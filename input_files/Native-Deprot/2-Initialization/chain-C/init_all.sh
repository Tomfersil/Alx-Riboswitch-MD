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
#SBATCH --job-name=Init_9JGM     # The name of your job, you'll se it in squeue.
#SBATCH --mail-type=NONE              # Mail events (NONE, BEGIN, END, FAIL, ALL). Sends you an email when the job begins, ends, or fails; you can combine options.
#SBATCH --mail-user=tfernand@sissa.it    # Where to send the mail
#
# ---- CPU resources configuration  ----  |  Clarifications at https://slurm.schedmd.com/mc_support.html
#
#SBATCH --nodes=1                   # Number of nodes (1 for serial job)
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=2            # Number of MPI ranks (1 for MPI serial job)
#SBATCH --cpus-per-task=8       # Number of threads per MPI rank (MAX: 2x32 cores on _partition_2, 2x20 cores on _partition_1)
#SBATCH --account=Sis25_bussi
#[optional] #SBATCH --ntasks-per-core=1          # How many tasks on each core (set to 1 to be sure that different tasks run on different cores on multi-threaded systems)
#
# ---- Other resources configuration (e.g. GPU) ----
#
#SBATCH --gres=gpu:2                         # Total number of GPUs for the job (MAX: 2 x number of nodes, only available on gpu1 and gpu2)
#SBATCH --gpus-per-node=2            # Number of GPUs per node (MAX: 2, only available on gpu1 and gpu2)
#SBATCH --gpus-per-task=1            # Number of GPUs per MPI rank (MAX: 2, only available on gpu1 and gpu2); to be used with --ntasks

# ---- Memory configuration ----
#
#SBATCH --mem=7900mb                 # Memory per node (MAX: 63500 on the new ones, 40000 on the old ones); incompatible with --mem-per-cpu.
#[optional] #SBATCH --mem-per-cpu=4000mb         # Memory per thread; incompatible with --mem
#
# ---- Partition, Walltime and Output ----
#
#[unconfig] #SBATCH --array=01-10    # Create a job array. Useful for multiple, similar jobs. To use, read this: https://slurm.schedmd.com/job_array.html
#SBATCH --partition=boost_usr_prod    # Partition (queue). Avail: regular1, regular2, long1, long2, wide1, wide2, gpu1, gpu2. Multiple partitions are possible.
#SBATCH --time=10:00:00              # Time limit hrs:min:sec
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
#     export PATH=:/my/custom/path/:\$PATH
#     export MAGMA_NUM_GPUS=2
#
#
module unload fftw
module load cuda
module load gromacs/2022.3--openmpi--4.1.4--gcc--11.3.0-cuda-11.8

export OMP_PLACES=threads
export GMX_GPU_DD_COMMS=true
export GMX_GPU_PME_PP_COMMS=true
#export GMX_FORCE_UPDATE_DEFAULT_GPU=true
#export GMX_ENABLE_DIRECT_GPU_COMM=true
export GMX_DISABLE_GPU_TIMING=true

# ==== End of Modules part (load all the modules) ===== #
#
#
# ==== Info part (say things) ===== #
#   DO NOT MODIFY. This part prints useful info on your output file.
#
NOW=`date +%H:%M-%a-%d/%b/%Y`
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
echo 'SLURM: current home directory is '$(getent passwd \$SLURM_JOB_ACCOUNT | cut -d: -f6)
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

Dir=`pwd`

grom=gmx_mpi
sys=9JGM-C
ndx=$Dir/../01_box-min/index.ndx


#cp $Dir/../01_box-min/posre.itp $Dir/../01_box-min/${sys}_init1.itp
#cp $Dir/../01_box-min/$sys.top $Dir/../01_box-min/${sys}_init1.top
#sed -i "s/posre.itp/${sys}_init1.itp/g" $Dir/../01_box-min/${sys}_init1.top
#cp $Dir/../01_box-min/${sys}_init1.itp .
#
##
#
#
#$grom grompp -f init1.mdp -c $Dir/../01_box-min/min3.gro -r $Dir/../01_box-min/min3.gro -p $Dir/../01_box-min/${sys}_init1.top -n $ndx -o init1.tpr -nice 19 -maxwarn 100 >> ${sys}.out 2>> ${sys}.err
#mpirun -np $SLURM_NTASKS $grom mdrun -v -deffnm init1 -pin on -npme 1 -ntomp $SLURM_CPUS_PER_TASK  -nb gpu -pme gpu -tunepme >> init1.out 2>> init1.err
#
#
### Init2.itp and init2.top
#cp $Dir/../01_box-min/$sys.top $Dir/../01_box-min/${sys}_init2.top
#sed 's/1000  1000  1000/100  100  100/g' $Dir/../01_box-min/posre.itp > $Dir/../01_box-min/${sys}_init2.itp
#sed -i "s/posre.itp/${sys}_init2.itp/g" $Dir/../01_box-min/${sys}_init2.top
#cp $Dir/../01_box-min/${sys}_init2.itp .
#
#$grom grompp -f init2.mdp -c $Dir/init1.gro -r $Dir/init1.gro -p $Dir/../01_box-min/${sys}_init2.top -n $ndx -o init2.tpr -nice 19 -maxwarn 100 >> ${sys}.out 2>> ${sys}.err
#mpirun -np $SLURM_NTASKS $grom mdrun -v -deffnm init2 -pin on -ntomp $SLURM_CPUS_PER_TASK -npme 1 -bonded gpu -pme gpu -nb gpu -tunepme >> init2.out 2>> init2.err
#
### Init3.itp and init3.top
#cp $Dir/../01_box-min/$sys.top $Dir/../01_box-min/${sys}_init3.top
#sed 's/1000  1000  1000/10  10  10/g' $Dir/../01_box-min/posre.itp > $Dir/../01_box-min/${sys}_init3.itp
#sed -i "s/posre.itp/${sys}_init3.itp/g" $Dir/../01_box-min/${sys}_init3.top
#cp $Dir/../01_box-min/${sys}_init3.itp .
#
#$grom grompp -f init3.mdp -c $Dir/init2.gro -r $Dir/init2.gro -p $Dir/../01_box-min/${sys}_init3.top -n $ndx -o init3.tpr -nice 19 -maxwarn 100 >> ${sys}.out 2>> ${sys}.err
#mpirun -np $SLURM_NTASKS $grom mdrun -v -deffnm init3 -pin on -bonded gpu -pme gpu -nb gpu -npme 1 -dlb auto -tunepme>> init3.out 2>> init3.err

# Init4
$grom grompp -f init4.mdp -c $Dir/init3.gro -r $Dir/init3.gro -p $Dir/../01_box-min/${sys}.top -n $ndx -o init4.tpr -nice 19 -maxwarn 100 >> ${sys}.out 2>> ${sys}.err
mpirun -np $SLURM_NTASKS $grom mdrun -v -deffnm init4 -pin on -bonded gpu -pme gpu -nb gpu -ntomp $SLURM_CPUS_PER_TASK -npme 1 -tunepme -dlb auto >> init4.out 2>> init4.err
