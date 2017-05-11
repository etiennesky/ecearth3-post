#/bin/bash

if [ "$#" -lt 1 ]; then
   echo "Usage: timeseries.sh exp [user]"
   echo "Compute timeseries for experiment exp of user (optional)"
   exit
fi

set -xuve

exp=$1

. $HOME/ecearth3/post/conf/conf_users.sh
. $CONFDIR/conf_timeseries_$MACHINE.sh

if [ "$#" -eq 2 ]; then
   USERexp=$2
fi

conf=$MACHINE
PROGDIR=$EMOP_DIR

#Atmospheric timeseries

cd $PROGDIR
./monitor_atmo.sh -C $conf -R $exp -o
./monitor_atmo.sh -C $conf -R $exp -e

#Oceanic timeseries

if $do_ocean ; then

check=$( ls $POST_DIR/mon/Post_*/*sosaline* )

if [ -z $check ] ; then
echo "Atm-only!" 
else
./monitor_ocean.sh -C $conf -R $exp
./monitor_ocean.sh -C $conf -R $exp -e
fi

fi

# remember to add -f flag to force

# create a tar and prepare the copy
#DIR_TIME_SERIES=/perm/ms/it/ccjh/ecearth3/diag/timeseries
mkdir -p ${DIR_TIME_SERIES}
cd ${DIR_TIME_SERIES}
rm -r -f  timeseries_$exp.tar
tar cfv timeseries_$exp.tar  $exp/
if $do_trans; then
ectrans -remote sansone -source timeseries_$exp.tar  -put -verbose -overwrite
ectrans -remote sansone -source ~/EXPERIMENTS.$MACHINE.$USERme.dat -verbose -overwrite
fi
