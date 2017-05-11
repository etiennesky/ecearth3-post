#!/bin/bash

# configuration file for hiresclim script
# add here machine dependent set up
# It expects USER* variables defined in conf_users.sh

# load required modules
module load NCO netCDF Python CDO CDFTOOLS

############################
#---standard definitions---#
############################

#program folder
if [ -z "${PROGDIR-}" ] ; then
PROGDIR=/home/Earth/$USER0/ecearth3/post/hiresclim2
fi

# required programs, including compression options
cdo="cdo"
cdozip="$cdo -f nc4c -z zip"
#ET HERE add rebuild_nemo cdftoolsbin
rbld="/perm/ms/it/$USER0/ecearth3/rebuild_nemo/rebuild_nemo"
cdftoolsbin="/usr/local/apps/cdftools/3.0/bin"
python="python"


# number of parallel procs for IFS (max 12) and NEMO rebuild
if [ -z "${IFS_NPROCS-}" ] ; then
IFS_NPROCS=1; NEMO_NPROCS=1
fi

# NEMO resolution
export NEMOCONFIG=ORCA025L75

# where to find mesh and mask files 
#ET HERE add nemo mesh masks
export MESHDIR=/esnas/scratch/etourign/ecearth3-post/data/nemo/$NEMOCONFIG

# where to find the results from the EC-EARTH experiment
# On our machine Nemo and IFS results are in separate directories
# ET HERE for now you need to make a symlink to the actual folder
# e.g. ln -s /esarchive/exp/ecearth/a0ez/original_files/19500101/fc0/outputs/ /esnas/scratch/etourign/ecearth3-post/exp/a0ez
#export BASERESULTS=${SCRATCH}/ecearth3-post/exp/$expname/outputs
export BASERESULTS=/esnas/scratch/etourign/ecearth3-post/exp/$expname/outputs
#export BASERESULTS=/esarchive/exp/ecearth/$expname/original_files/19500101/fc0/outputs/

# cdo table for conversion GRIB parameter --> variable name
export ecearth_table=$PROGDIR/script/ecearth.tab

# where to produce the results
export OUTDIR0=/esnas/scratch/etourign/ecearth3-post/exp/$expname/post
#export OUTDIR0=${SCRATCH}/ecearth3-post/exp/$expname/post
mkdir -p $OUTDIR0

#where to archive the monthly results (daily are kept in scratch)
#STOREDIR=/home/hpc/pr45de/di56bov/work/ecearth3/post/hiresclim/${expname}
#mkdir -p $STOREDIR || exit -1

# create a temporary directory
#export TMPDIR=/esnas/scratch/etourign/ec-mean/tmp/post_${expname}_$RANDOM
export TMPDIR=${SCRATCH}/ecearth3-post/tmp/post_${expname}_$RANDOM
mkdir -p $TMPDIR || exit -1

#ET HERE fix this!!!
export GRB_EXT=".grb"
export PPTIME=21600 #6h, default
#export PPTIME=10800 #3h

echo Script is running in $PROGDIR
echo Temporary files are in $TMPDIR
echo Output are placed in $OUTDIR0
echo IFS procs are $IFS_NPROCS and NEMO procs are $NEMO_NPROCS
echo 
echo

