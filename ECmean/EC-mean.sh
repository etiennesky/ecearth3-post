#!/bin/bash

#fast wrapper script that recall scripts for PI and RK analysis
#firstly interpolate on common 2x2 grid hiresclim outputs
#hence computes RK08 diagnostics and finally produces
#global mean values for radiation and some selected fields

#Paolo Davini (ISAC-CNR) - <p.davini@isac.cnr.it> 
#December 2014

#Important: script folder and properties depend from config.sh file


if [ $# -lt 3 ]
then
  echo "Usage:   ./EC-mean.sh exp YEARSTART YEAREND"
  echo "Example: ./EC-mean.sh io01 1990 2000"
  exit 1
fi

# experiment name
exp=$1
# years to be processed
year1=$2
year2=$3

#Configuration
. $HOME/ecearth3/post/conf/conf_users.sh
. $CONFDIR/conf_ecmean_$MACHINE.sh

if [ "$#" -eq 4 ]; then
   USERexp=$4
fi

cd $PIDIR/scripts/ 

#executing files
mkdir -p $OUTDIR
./post2x2.sh $exp $year1 $year2
./oldPI2.sh $exp $year1 $year2
./PI3.sh $exp $year1 $year2
./global_mean.sh $exp $year1 $year2

#rearranging in a single table the PI from the old and the new versions
cat $OUTDIR/PIold_RK08_${exp}_${year1}_${year2}.txt $OUTDIR/PI2_RK08_${exp}_${year1}_${year2}.txt > $TMPDIR/out.txt
rm $OUTDIR/PI2_RK08_${exp}_${year1}_${year2}.txt $OUTDIR/PIold_RK08_${exp}_${year1}_${year2}.txt
mv $TMPDIR/out.txt $OUTDIR/PI2_RK08_${exp}_${year1}_${year2}.txt 

#deleting the 2x2 climatology to save space
rm $CLIMDIR/*.nc
rmdir $CLIMDIR
cd $OUTDIR/..
touch globtable.txt globtable_cs.txt
$PIDIR/tab2lin_cs.sh $exp $year1 $year2 >> ./globtable_cs.txt
$PIDIR/tab2lin.sh $exp $year1 $year2 >> ./globtable.txt
#finalizing
cd -
echo "table produced"

cd $OUTDIR/..
rm -r -f ecmean_$exp.tar 
rm -r -f ecmean_$exp.tar.gz
tar cvf ecmean_$exp.tar $exp
gzip ecmean_$exp.tar

if $do_trans; then
    ectrans -remote sansone -source ecmean_$exp.tar.gz  -verbose -overwrite
    ectrans -remote sansone -source ~/EXPERIMENTS.$MACHINE.$USERme.dat -verbose -overwrite
fi

