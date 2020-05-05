#!/bin/bash
#
#SBATCH -J fmriprep
#SBATCH --array=1  # Replace indices with the right number of subjects
#SBATCH --time=60:00:00
#SBATCH -n 1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G
# Outputs ----------------------------------
#SBATCH -o %x-%A-%a.out
#SBATCH -e %x-%A-%a.err
#SBATCH --mail-user=ruonan.jia@yale.edu # replace with your email
#SBATCH --mail-type=ALL
# ------------------------------------------

SUBJ=(1304)

BIDS_DIR="/gpfs/ysm/project/levy_ifat/share/ra_ptsd/data_bids"
# BIDS_DIR="/home/rj299/scratch60/ra_ptsd/data_bids" # change directory
DERIVS_DIR="/home/rj299/scratch60/ra_ptsd/fmriprep/derivatives" # the end point folder for fmriprep (should be in derivatives so don't touch unless you're know what yoou're doing)
WORK_DIR="/home/rj299/scratch60/ra_ptsd/work" # enter working directory here

mkdir -p $HOME/.cache/templateflow
# mkdir -p ${BIDS_DIR}/${DERIVS_DIR}
mkdir -p ${DERIVS_DIR}
# mkdir -p ${BIDS_DIR}/derivatives/freesurfer-6.0.1
mkdir -p ${DERIVS_DIR}/freesurfer-6.0.1
# ln -s ${BIDS_DIR}/derivatives/freesurfer-6.0.1 ${BIDS_DIR}/${DERIVS_DIR}/freesurfer
ln -s ${DERIVS_DIR}/freesurfer-6.0.1 ${DERIVS_DIR}/freesurfer


export SINGULARITYENV_FS_LICENSE=$HOME/freesurfer_license/licenseFreeSurfer.txt # freesurfer license file
export SINGULARITYENV_TEMPLATEFLOW_HOME="/templateflow"
SINGULARITY_CMD="singularity run --cleanenv -B $HOME/.cache/templateflow:/templateflow -B ${WORK_DIR}:/work /project/ysm/levy_ifat/fmriPrep/fmriprep-1.5.8.simg"



# cmd="${SINGULARITY_CMD} ${BIDS_DIR} ${BIDS_DIR}${DERIVS_DIR} participant --skip_bids_validation --participant-label ${SUBJ[$SLURM_ARRAY_TASK_ID-1]} -w /work/ -vv --omp-nthreads 8 --nthreads 12 --mem_mb 30000 --output-spaces MNI152NLin2009cAsym:res-2 anat fsnative fsaverage5 --cifti-output --use-aroma"

cmd="${SINGULARITY_CMD} ${BIDS_DIR} ${DERIVS_DIR} participant --skip_bids_validation --participant-label ${SUBJ[$SLURM_ARRAY_TASK_ID-1]} -w /work/ -vv --omp-nthreads 8 --nthreads 12 --mem_mb 30000 --output-spaces MNI152NLin2009cAsym:res-2 anat fsnative fsaverage5 --cifti-output --use-aroma"

# Setup done, run the command
echo Running task ${SLURM_ARRAY_TASK_ID}
echo Commandline: $cmd
eval $cmd
exitcode=$?

# Output results to a table
echo "sub-$subject   ${SLURM_ARRAY_TASK_ID}    $exitcode" \
      >> ${SLURM_JOB_NAME}.${SLURM_ARRAY_JOB_ID}.tsv
echo Finished tasks ${SLURM_ARRAY_TASK_ID} with exit code $exitcode
exit $exitcode
