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
PROGDIR=${ECE3POST_ROOT}/hiresclim2
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
#ET HERE implement do_ocean
#export MESHDIR=/esnas/scratch/etourign/ecearth3-post/data/nemo/$NEMOCONFIG
export NEMO_MESH_DIR=/esnas/autosubmit/con_files/ecearth3-post/nemo/$NEMOCONFIG

# where to find the results from the EC-EARTH experiment
# On our machine Nemo and IFS results are in separate directories
# ET HERE for now you need to make a symlink to the actual folder
# e.g. mkdir -p /esarchive/exp/ecearth/a0ez/ecearth3-post && ln -s /esarchive/exp/ecearth/a0ez/original_files/19500101/fc0/outputs/ /esarchive/exp/ecearth/a0ez/ecearth3-post/outputs/
#export BASERESULTS=/esnas/scratch/etourign/ecearth3-post/exp/$expname/outputs
export BASERESULTS=/esarchive/exp/ecearth/$expname/ecearth3-post/outputs/

# cdo table for conversion GRIB parameter --> variable name
export ecearth_table=$PROGDIR/script/ecearth.tab

# where to produce the results
#export OUTDIR0=${SCRATCH}/ecearth3-post/exp/$expname/post
export OUTDIR0=/esarchive/exp/ecearth/$expname/ecearth3-post/post
mkdir -p $OUTDIR0

#where to archive the monthly results (daily are kept in scratch)
#STOREDIR=/home/hpc/pr45de/di56bov/work/ecearth3/post/hiresclim/${expname}
#mkdir -p $STOREDIR || exit -1

# create a temporary directory
#export TMPDIR=/esnas/scratch/etourign/ec-mean/tmp/post_${expname}_$RANDOM
export TMPDIR=${SCRATCH}/ecearth3-post/tmp/post_${expname}_$RANDOM
mkdir -p $TMPDIR || exit -1

#ET HERE fix ifs_monthly.sh!!!
export GRB_EXT=".grb"
#ET HERE find a way to specify PPTIME when needed, for now it is hard-coded
export PPTIME=21600 #6h, default
#export PPTIME=10800 #3h, e.g. PRIMAVERA
if [[ "$expname" == "a0ez" ]] ; then export PPTIME=10800 ; fi

echo Script is running in $PROGDIR
echo Temporary files are in $TMPDIR
echo Output are placed in $OUTDIR0
echo IFS procs are $IFS_NPROCS and NEMO procs are $NEMO_NPROCS
echo 
echo

