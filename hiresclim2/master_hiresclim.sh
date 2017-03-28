#!/bin/ksh

# Wrapper of postprocessing utility 
# Requires: 	1) CDO with netcdf4 for IFS postprocessing
#		2) rebuildndemo and cdftools for NEMO postprocessing	
#		3) python for relative humidity
#		4) nco for supplementary NEMO diags

# Produces IFS postprocessing on monthly, daily and 6hrs basis
# together with  monthly averages for NEMO


##########################
#----user defined var----#
##########################
if [ $# -lt 3 ]
then
  echo "Usage:   ./master_hiresclim.sh EXP YEAR1 YEAR2 [user]"
  echo "Example: ./master_hiresclim.sh io01 1990 1991 ccjh"
  exit 1
fi

expname=$1
YEAR1=$2
YEAR2=$3

. $HOME/ecearth3/post/conf/conf_users.sh
. $CONFDIR/conf_hiresclim_$MACHINE.sh

if [ $# -eq 4 ]; then
   USERexp=$4
fi

#########################
STOREDIR=$OUTDIR0

# Flags: 0 is false, 1 is true
# monthly flag for standard hiresclim
# daily and 6hrs flag for u,v,t,z 3d field + tas,totp extraction
ifs_monthly=1
ifs_daily=0
ifs_6hrs=0

# extract NEMO standard and NEMO extra-fields; extra-fields require NCO
nemo=0
nemo_extra=0

# build 3D relative humidity; require python
rh_build=1

#store monthly results in a second folder
store=0

#save postcheck file
fstore=1

cd $PROGDIR/script

######################################
#-----here start the computations----#
######################################
for (( year=$YEAR1; year<=$YEAR2; year++ )); do

  start1=$(date +%s)
	if [ $ifs_monthly == 1 ] ; then	
	. ./ifs_monthly.sh $expname $year
	fi

	if [ $ifs_daily == 1 ] ; then
	. ./ifs_daily.sh $expname $year
	fi

	if [ $ifs_6hrs == 1 ] ; then
        . ./ifs_6hrs.sh $expname $year
        fi

	if [ $nemo == 1 ] ; then
	. ./nemo_post.sh $expname $year $nemo_extra
	fi

	if [ $rh_build == 1 ] ; then
	. ../config.sh
	$python ../rhbuild/build_RH_new.py $expname $year
	fi

  end1=$(date +%s)
  runtime=$((end1-start1));
  hh=$(echo "scale=3; $runtime/3600" | bc)
  echo "One year postprocessing runtime is $runtime sec (or $hh hrs) "
  echo; echo

  if [ $fstore == 1 ] ; then      
                mkdir -p $STOREDIR
                echo "$expname for $year has been postprocessed successfully" > $STOREDIR/postcheck_${expname}_${year}.txt
                echo "Postprocessing lasted for $runtime sec (or $hh hrs)" >> $STOREDIR/postcheck_${expname}_${year}.txt
                echo "Configuration: MON: $ifs_monthly ; DAY: $ifs_daily ; 6HRS: $ifs_6hrs; CDX: $ifs_3hrs_cdx ; SMON: $ifs_smon ; NONLIN: $ifs_nonlinear"  >> $STOREDIR/postcheck_${expname}_${year}.txt
                echo $(date) >> $STOREDIR/postcheck_${expname}_${year}.txt

  fi

done

#copy monthlydata
if [ $store == 1 ] ; then
cp -r --update $OUTDIR0/mon/ ${STOREDIR}/
fi



# clean up
rm -r $TMPDIR

exit 0
