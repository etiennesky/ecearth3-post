#!/bin/bash

. $HOME/ecearth3/post/conf/conf_users.sh

#CONFIG FILE FOR PI/global mean scripts
#Paolo Davini (ISAC-CNR) - <p.davini@isac.cnr.it> 
#December 2014

#machine-dependent commands ....
module load cdo

#Where the program is placed
PIDIR=/home/ms/it/${USER0}/ecearth3/post/ECmean

#Base directory where the postprocessing outputs are located
#This will be evaluated later, use ${year} and ${exp} 
DATADIR='/scratch/ms/it/$USERexp/ece3/${exp}/post/mon/Post_$year'

#Where to save the table produced
OUTDIR=/perm/ms/it/${USERme}/ecearth3/diag/table/${exp}

#Where to store the 2x2 climatologies
CLIMDIR=/scratch/ms/it/$USERme/tmp/${exp}/post/model2x2_${year1}_${year2}

#Where to store the RKnew climatologies
MODDIR=/scratch/ms/it/$USERme/tmp/${exp}/post/rknew_${year1}_${year2}

TMPDIR=/scratch/ms/it/$USERme/tmp/ECmean_${exp}_${RANDOM}
mkdir -p $TMPDIR

# Required programs, including compression options
cdo="/usr/local/apps/cdo/1.6.1/bin/cdo"
cdozip="$cdo -f nc4c -z zip"
cdonc="$cdo -f nc"

#preferred type of CDO interpolation (curvilinear grids are obliged to use bilinear)
remap="remapcon2"

#mask files
#2x2 grids for interpolation are included in the Climate_netcdf folder (derived from IFS land sea mask)
#T255 masks (or theoretically different resolution) are used by ./global_mean.sh 
#and by ./post2x2.sh scripts. They are computed from the original initial conditions of IFS (using var 172)
#maskfile=/lus/snx11062/scratch/ms/it/${USER}/ecearth3/setup/ifs/T255L91/19900101/ICMGGECE3INIT
maskfile=/perm/ms/nl/nm6/ECE3-DATA/ifs/T255L91/19900101/ICMGGECE3INIT

