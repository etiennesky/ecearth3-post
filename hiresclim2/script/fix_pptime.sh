#!/bin/bash

#set -ex

#prefix=/scratch/Earth/etourign/ecearth3-post/exp/a0ez
#years=`seq 1950 1976`
years=1950
vars="ro sf totp e lsp cp pme ssr str sshf ssrd strd slhf tsr ttr ewss nsss ssrc strc tsrc ttrc snr tnr"
expname=a0ez

. /home/Earth/etourign/ecearth3/post/hiresclim2/script/../config.sh

#go to temp dir
cd $TMPDIR

#where to get the files
#IFSRESULTS=$BASERESULTS/Output_$year/IFS
IFSRESULTS=$BASERESULTS


for year in $years ; do

    echo $OUTDIR0
    OUTDIR=$OUTDIR0/mon/Post_$year
    echo $OUTDIR
    OUTDIR1=$OUTDIR0/../post.bak/mon/Post_$year
    echo $OUTDIR1
    mkdir -p $OUTDIR


    for var in $vars ; do
        f=${expname}_${year}_${var}.nc
        echo $year $var $f
        $cdozip mulc,2.0 $OUTDIR1/$f $OUTDIR/$f         
    done

    cp -n $OUTDIR1/* $OUTDIR
    
    cp $OUTDIR0/../post.bak/postcheck_${expname}_${year}.txt   $OUTDIR0/postcheck_${expname}_${year}.txt

done
