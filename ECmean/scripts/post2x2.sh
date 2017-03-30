#!/bin/bash

# Prepares regridded 2x2 degree files for use with the RK PI scripts
# starting from the output of the HiResClim postprocessing tool
# This scripts substitutes post_data.sc of the RK PI scripts
# The output nc files are in nc1 classic format
# j.vonhardenberg@isac.cnr.it

#Updated by P. Davini (ISAC-CNR) - <p.davini@isac.cnr.it> 
#December 2014

# Usage:   ./post2x2.sh exp YEARSTART YEAREND
# Example: ./post2x2.sh io01 1990 2000

if [ $# -ne 3 ]
then
  echo "Usage:   ./post2x2.sh exp YEARSTART YEAREND"
  echo "Example: ./post2x2.sh io01 1990 2000"
  exit 1
fi


# experiment name
exp=$1
# years to be processed
year1=$2
year2=$3

#set config.sh to configure folders and cdo details
. $CONFDIR/conf_ecmean_$MACHINE.sh

# Where the PI climatologies are located
PICLIM=$PIDIR/Climate_netcdf

############################################
# No need to touch below this line 
# (but check the FBASE line below and adapt for your system)
############################################
REFGRID=$PICLIM/reference_grid_2x2.nc
OCEREFGRID=$PICLIM/opa_grid_2x2.nc
mkdir -p $CLIMDIR || exit -1

#cleaning directories
rm -f $CLIMDIR/*_mon_2x2.nc  $CLIMDIR/*_mean_2x2.nc

#loop on years
for (( year=$year1; year<=$year2; year++)); do

#select files
mydir=$(eval echo $DATADIR)
FBASE=$mydir/${exp}_$year

#  T2M [convert to Celcius]
$cdonc cat -$remap,$REFGRID -addc,-273.15 ${FBASE}_tas.nc $CLIMDIR/t2m_mon_2x2.nc

#  MSL [from Pa to hPa]
$cdonc cat -$remap,$REFGRID -divc,100.0 ${FBASE}_msl.nc $CLIMDIR/msl_mon_2x2.nc

# IFS Net Surface Heat Flux QNET=SLHF+SSHF+SSR+STR [already in W/m2]
$cdonc add ${FBASE}_slhf.nc ${FBASE}_sshf.nc $CLIMDIR/shf$$.nc
$cdonc add ${FBASE}_str.nc ${FBASE}_ssr.nc $CLIMDIR/sr$$.nc
$cdonc cat -$remap,$REFGRID -add $CLIMDIR/sr$$.nc  $CLIMDIR/shf$$.nc $CLIMDIR/qnet_mon_2x2.nc
rm $CLIMDIR/sr$$.nc  $CLIMDIR/shf$$.nc

# Total precipitation [from Kg/m2/s to mm/day] 
$cdonc cat -$remap,$REFGRID -mulc,86400.0 ${FBASE}_totp.nc $CLIMDIR/tp_mon_2x2.nc

# East-west surface stress [already in N/m2]
$cdonc cat -$remap,$REFGRID ${FBASE}_ewss.nc $CLIMDIR/ewss_mon_2x2.nc

# North-south surface stress [already in N/m2]
$cdonc cat -$remap,$REFGRID ${FBASE}_nsss.nc $CLIMDIR/nsss_mon_2x2.nc

# T, U, V, Q on p levels [units already ok]
$cdonc cat -$remap,$REFGRID ${FBASE}_t.nc $CLIMDIR/T_mon_2x2.nc
$cdonc cat -$remap,$REFGRID ${FBASE}_u.nc $CLIMDIR/U_mon_2x2.nc
$cdonc cat -$remap,$REFGRID ${FBASE}_v.nc $CLIMDIR/V_mon_2x2.nc
$cdonc cat -$remap,$REFGRID ${FBASE}_q.nc $CLIMDIR/Q_mon_2x2.nc

# ET HERE fix nemo hiresclim first!
if $do_ocean ; then
    
# NEMO fields: we reconstruct the mask from the salinity field
OCEMASK=$CLIMDIR/tmask.nc
$cdonc seltimestep,1 -gtc,0 ${FBASE}_sosaline.nc  $OCEMASK

#SST, SIC, SSS
$cdonc cat -invertlat -remapbil,$OCEREFGRID -ifthen $OCEMASK ${FBASE}_sosstsst.nc $CLIMDIR/SST_mon_2x2.nc
$cdonc cat -invertlat -remapbil,$OCEREFGRID -ifthen $OCEMASK ${FBASE}_sosaline.nc $CLIMDIR/SSS_mon_2x2.nc
$cdonc cat -invertlat -remapbil,$OCEREFGRID -ifthen $OCEMASK -selname,iiceconc ${FBASE}_ice.nc $CLIMDIR/SICE_mon_2x2.nc
rm $OCEMASK

fi

done

#time mean for all fields

#for vv in t2m msl qnet tp ewss nsss T U V Q SST SSS SICE ; do
if $do_ocean ; then
    vvars="t2m msl qnet tp ewss nsss T U V Q SST SSS SICE"
else
    vvars="t2m msl qnet tp ewss nsss T U V Q"
fi
for vv in ${vvars} ; do
        $cdonc timmean $CLIMDIR/${vv}_mon_2x2.nc $CLIMDIR/${vv}_mean_2x2.nc
done

# 2x2 mask, will be needed for PI 
$cdonc -R setctomiss,0 -ltc,0.5 -$remap,$CLIMDIR/qnet_mon_2x2.nc -selcode,172 $maskfile $CLIMDIR/ocean_mask2x2.nc
