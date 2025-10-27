#!/usr/bin/bash
ARGC=$#
if [[ $ARGC -ne 5 ]]; then
    echo "Usage: hcswif.sh SCRIPT RUN EVENTS APPTAINER RAWDIR"
    exit 1
fi;

script=$1 # script to run
run=$2 # RUN Number
evt=$3 # Number of events in that run
apptainer=$4
rawdir=$5

# Modify as you need
#--------------------------------------------------
VOL_PATH="/volatile/hallc/c-lad/${USER}/"
WORK_PATH="/work/hallc/c-lad/${USER}/"
CACHE_PATH="/cache/hallc/c-lad/"

HALLC_REPLAY_DIR="${WORK_PATH}lad_replay_farm"   # my replay directory
DATA_DIR="${rawdir}"
#ROOT_FILE="/path/to/rootfile/directory"
#REPORT_OUTPUT="/path/to/REPORT_OTUPUT/directory"
APPTAINER_IMAGE="${apptainer}"
#--------------------------------------------------

cd $HALLC_REPLAY_DIR

# Check if apptainer is available
if command -v apptainer > /dev/null 2>&1; then
    echo "apptainer is already available."
else
    # Load apptainer if not available
    echo "Loading apptainer..."
   if ! eval module load apptainer; then
        echo "Failed to load apptainer. Please check if the module is installed and accessible."
        exit 1  # Exit the script with a non-zero exit code
    fi
fi

BIND_PATH="${HALLC_REPLAY_DIR},${DATA_DIR},${VOL_PATH},${WORK_PATH},${CACHE_PATH},/cvmfs"

echo
echo "---------------------------------------------------------------------------------------------"
echo "REPLAY for ${runNum}. NEvent=${nEvent} using container=${APPTAINER_IMAGE}"
echo "----------------------------------------------------------------------------------------------"
echo

runStr="apptainer exec --bind ${BIND_PATH}  ${APPTAINER_IMAGE} bash -c \"hcana -l -b -q ${script}\(${runNum},${nEvent}\)\""
eval ${runStr}
