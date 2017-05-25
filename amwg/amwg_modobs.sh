#!/bin/bash

#set -xuve

if [ "$#" -lt 3 ]; then
   echo "Usage: "`basename $0`" exp year1 year2 [user] [resolution]"
   echo "Do AMWG analysis of experiment exp in years year1 to year2 for a specific user (optional) and resolution,"
   echo "where resolution is N128, N256 etc. (N128=default)"
   exit
fi

if [ "$#" -ge 5 ]; then
   resolution=$5
else
   resolution=N128
fi
if [ "$#" -ge 4 ]; then
   USERexp=$4
fi

expname=$1
year1=$2
year2=$3

#Configuration file
. ../conf/conf_users.sh
. $CONFDIR/conf_amwg_$MACHINE.sh

conf=$MACHINE
PROGDIR=$EMOP_DIR

#first step is to ncarize the files created by hiresclim2
#the MMA files lack sp/PS/surface pressure and stl1/TS/surface temperature
cd $PROGDIR/ncarize
bash $PROGDIR/ncarize/ncarize_pd.sh -C $conf -R $expname -g $resolution -i ${year1} -e ${year2}
#second step is to run the AMWG diags
cd $PROGDIR/amwg_diag
bash $PROGDIR/amwg_diag/diag_mod_vs_obs.sh -C $conf -R $expname -P ${year1}-${year2}

if $do_trans; then
DIAGS=$EMOP_CLIM_DIR/diag_${expname}_${year1}-${year2}
cd $DIAGS
rm -r -f diag_${expname}.tar
tar cvf diag_${expname}.tar ${expname}-obs_${year1}-${year2}
ectrans -remote sansone -source diag_${expname}.tar -verbose -overwrite
ectrans -remote sansone -source ~/EXPERIMENTS.$MACHINE.$USERme.dat -verbose -overwrite
fi

echo
echo "done ""`basename $0`"
