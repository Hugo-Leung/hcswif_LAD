#! /bin/bash
# This script must be sourced in a bash shell, not csh/tcsh.
#sg c-nps #Set group to c-nps, so files go into /mss/ properly (hopefully)


#source /apps/modules/5.2.0/init/profile.sh
#source /apps/modules/5.2.0/init/profile.csh
source /etc/profile

module use /cvmfs/oasis.opensciencegrid.org/jlab/scicomp/sw/el9/modulefiles

# for root
module load root/6.30.04-gcc11.4.0

# for hcana
cd /work/hallc/c-lad/$USER/software/hcana/
source setup.sh
cd -
export LD_LIBRARY_PATH="${HOME}/hallc/software/hcana/install/lib64:$LD_LIBRARY_PATH"
export PATH="${HOME}/hallc/software/hcana/install/bin:$PATH"
export HCANA="$HCANALYZER"
# for LAD
export LD_LIBRARY_PATH="${HOME}/hallc/software/LADlib/install/lib64:$LD_LIBRARY_PATH"
export PATH="${HOME}/hallc/software/LADlib/install/include:$PATH"

echo " Setting hcana from: "
echo $HCANA
echo " Edit this file if you want to use different hcana"
#    setenv LD_LIBRARY_PATH "$LD_LIBRARY_PATH":$HCANA/lib64
#    setenv PATH "$PATH":$HCANA/bin

# for hallc_replay
export DB_DIR=DBASE

# module use /group/halla/modulefiles
# module use /group/nps/modulefiles
# module load nps_replay/5.28.24
#setenv LD_LIBRARY_PATH /group/nps/$USER/NPSlib/BUILD/lib64:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/group/nps/$USER/NPSlib/BUILD/lib64:$LD_LIBRARY_PATH


# -----------------------------------------------------------------------------
#  Change these if this if not where hallc_replay and hcana live
#export REPLAYDIR=/group/nps/$USER/nps_replay
echo "Modules in use:"
module list
echo "This is the PATH variable:"
echo $PATH
echo "This is LD_LIBRARY_PATH"
echo $LD_LIBRARY_PATH
# Source setup scripts
curdir=`pwd`

cd $REPLAYDIR
#source setup.sh
#echo Sourced $REPLAYDIR/setup.sh

echo cd back to $curdir
cd $curdir

