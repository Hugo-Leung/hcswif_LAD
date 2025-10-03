#!/usr/bin/bash

ARGC=$#
if [[ $ARGC -ne 5 ]]; then
    echo Usage: hcswif.sh SCRIPT RUN EVENTS FILETYPE SEGMENT
    exit 1
fi;
script=$1
run=$2
evt=$3
fileType=$4
seg=$5
apptainer="apptainer_image.sif"

#Define paths - modify as you need
#--------------------------------------------------
VOL_PATH="/volatile/hallc/c-lad/${USER}/"
WORK_PATH="/work/hallc/c-lad/${USER}/"
CACHE_PATH="/cache/hallc/c-lad/"
hallc_replay_dir="${WORK_PATH}lad_replay_farm"   # my replay directory

BIND_PATH="${hallc_replay_dir},${VOL_PATH},${WORK_PATH},${CACHE_PATH}"

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

# Replay the run
runHcana="hcana -q \"$script($run,$evt,$fileType,1,$seg,$seg)\""
#runHcana="hcana -q \"$script($run,$evt)\""

#cd $hallc_replay_dir
tar -xf lad_replay.tar.gz

echo pwd: $(pwd)
echo $runHcana
apptainer exec --bind ${BIND_PATH}  ${apptainer} bash -c "${runHcana}"