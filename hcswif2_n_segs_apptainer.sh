#!/usr/bin/bash

#SBATCH --qos=longrun
#SBATCH --time=3-00:00:00 

ARGC=$#
if [[ $ARGC -ne 6 ]]; then
    echo Usage: hcswif.sh SCRIPT RUN EVENTS FILETYPE SEG_END SEG_START 
    exit 1
fi;
script=$1
run=$2
evt=$3
fileType=$4
seg_end=$5
seg_start=$6
apptainer="apptainer_image.sif"

#Define paths - modify as you need
#--------------------------------------------------
VOL_PATH="/volatile/hallc/c-lad/${USER}/"
WORK_PATH="/work/hallc/c-lad/${USER}/"
CACHE_PATH="/cache/hallc/c-lad/"
hallc_replay_dir="${WORK_PATH}lad_replay_farm"   # my replay directory

PATH_LIST=(${hallc_replay_dir} ${VOL_PATH} ${WORK_PATH} ${CACHE_PATH} "/cvmfs")

#check if the path is already in $APPTAINER_BINDPATH
for path in "${PATH_LIST[@]}"; do
    if [[ ",$APPTAINER_BINDPATH," != *",$path,"* ]]; then
        APPTAINER_BINDPATH="${APPTAINER_BINDPATH},${path}"
    fi
done

export APPTAINER_BINDPATH="${APPTAINER_BINDPATH#,}"  # Remove leading comma if exists

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

apptainer inspect ${apptainer} # To check if the image is valid and print out the labels
if [ $? -ne 0 ]; then
    echo "Error: Apptainer image ${apptainer} is not valid."
    exit 1
fi

# Replay the run
runHcana="hcana -q -b -l \"$script($run,$evt,$fileType,1,$seg_end,$seg_start)\""
#runHcana="hcana -q \"$script($run,$evt)\""

#cd $hallc_replay_dir
tar -xf lad_replay.tar.gz
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract lad_replay.tar.gz"
    exit 1
fi

#check if this is a git repo and print the git hash
if [ -d ".git" ]; then
    echo "REPLAY HASH:" $(git rev-parse HEAD) 
fi

echo pwd: $(pwd)
echo $runHcana
apptainer exec ${apptainer} bash -c "${runHcana}"
