#!/bin/bash

#CONFIG FILE FOR PI/global mean scripts
#Paolo Davini (ISAC-CNR) - <p.davini@isac.cnr.it> 
#December 2014

#machine-dependent commands ....
module load CDO

#Where the program is placed
PIDIR=${ECE3POST_ROOT}/ECmean

#Base directory where the postprocessing outputs are located
#This will be evaluated later, use ${year} and ${exp} 
#DATADIR='/esnas/scratch/etourign/ecearth3-post/exp/${exp}/post/mon/Post_$year'
DATADIR='/esarchive/exp/ecearth/${exp}/ecearth3-post/post/mon/Post_$year'


#Where to save the table produced
#OUTDIR=/esnas/scratch/etourign/ecearth3-post/diag/table/${exp}
OUTDIR=/esarchive/exp/ecearth/${exp}/ecearth3-post/diag/table
#Where to store table of all experiments
#we don't save to a common folder anymore, maybe they could go somewhere else
OUTDIR2=/esarchive/exp/ecearth/${exp}/ecearth3-post/diag/table

#Where to store the 2x2 climatologies
#CLIMDIR=/esnas/scratch/etourign/ecearth3-post/exp/${exp}/post/model2x2_${year1}_${year2}
CLIMDIR=${SCRATCH}/ecearth3-post/exp/${exp}/post/model2x2_${year1}_${year2}

#Where to store the RKnew climatologies
#MODDIR=/esnas/scratch/etourign/ecearth3-post/exp/${exp}/post/rknew_${year1}_${year2}
MODDIR=${SCRATCH}/ecearth3-post/exp/${exp}/post/rknew_${year1}_${year2}

#TMPDIR=/esnas/scratch/etourign/ecearth3-post/tmp/ECmean_${exp}_${RANDOM}
TMPDIR=${SCRATCH}/ecearth3-post/tmp/ECmean_${exp}_${RANDOM}
mkdir -p $TMPDIR

# Required programs, including compression options
cdo="cdo"
cdozip="$cdo -f nc4c -z zip"
cdonc="$cdo -f nc"

#preferred type of CDO interpolation (curvilinear grids are obliged to use bilinear)
remap="remapcon2"

#mask files
#2x2 grids for interpolation are included in the Climate_netcdf folder (derived from IFS land sea mask)
#T255 masks (or theoretically different resolution) are used by ./global_mean.sh 
#and by ./post2x2.sh scripts. They are computed from the original initial conditions of IFS (using var 172)
#maskfile=/lus/snx11062/scratch/ms/it/${USER}/ecearth3/setup/ifs/T255L91/19900101/ICMGGECE3INIT
#now actual maskfile to use is guessed in EC-mean.sh
maskfile_t255=/esnas/autosubmit/con_files/ecearth3-post/ifs/T255L91/19900101/ICMGGECE3INIT
maskfile_t511=/esnas/autosubmit/con_files/ecearth3-post/ifs/T511L91/19900101/ICMGGECE3INIT

# ET HERE add this flag elsewhere
# ET HERE fix nemo hiresclim first!
do_ocean=false

do_trans=false

set -xuve 
