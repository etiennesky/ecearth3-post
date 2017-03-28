#!/bin/bash

# configuration file for hiresclim script
# add here machine dependent set up
# It expects USER* variables defined in conf_users.sh

#special module load for ECMWF cca
module switch PrgEnv-cray PrgEnv-intel
module load nco netcdf python cdo cdftools

############################
#---standard definitions---#
############################

#program folder
if [ -z $PROGDIR ] ; then
PROGDIR=/home/ms/it/$USER0/ecearth3/post/hiresclim2
fi

# required programs, including compression options
cdo="/usr/local/apps/cdo/1.6.1/bin/cdo"
cdozip="$cdo -f nc4c -z zip"
rbld="/perm/ms/it/$USER0/ecearth3/rebuild_nemo/rebuild_nemo"
cdftoolsbin="/usr/local/apps/cdftools/3.0/bin"
python="/usr/local/apps/python/2.7.5-01/bin/python"


# number of parallel procs for IFS (max 12) and NEMO rebuild
if [ -z $IFS_NPROCS ] ; then
IFS_NPROCS=12; NEMO_NPROCS=12
fi

# NEMO resolution
export NEMOCONFIG=ORCA1L75

# where to find mesh and mask files 
export MESHDIR=/perm/ms/it/$USER0/ecearth3/nemo/$NEMOCONFIG

# where to find the results from the EC-EARTH experiment
# On our machine Nemo and IFS results are in separate directories
export BASERESULTS=/scratch/ms/it/$USERexp/ece3/$expname/output

# cdo table for conversion GRIB parameter --> variable name
export ecearth_table=$PROGDIR/script/ecearth.tab

# where to produce the results
export OUTDIR0=/scratch/ms/it/$USERme/ece3/$expname/post
mkdir -p $OUTDIR0

#where to archive the monthly results (daily are kept in scratch)
#STOREDIR=/home/hpc/pr45de/di56bov/work/ecearth3/post/hiresclim/${expname}
#mkdir -p $STOREDIR || exit -1

# create a temporary directory
export TMPDIR=/scratch/ms/it/$USERme/tmp/post_${expname}_$RANDOM
mkdir -p $TMPDIR || exit -1


echo Script is running in $PROGDIR
echo Temporary files are in $TMPDIR
echo Output are placed in $OUTDIR0
echo IFS procs are $IFS_NPROCS and NEMO procs are $NEMO_NPROCS
echo 
echo
