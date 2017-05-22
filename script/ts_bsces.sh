#!/bin/bash

usage()
{
   echo "Usage: ts.sh [-a account] [-u user] exp [user]"
   echo "Compute timeseries for experiment exp of user (optional)"
   echo "Options are:"
   echo "-a account    : specify a different special project for accounting (default: spnltune)"
   echo "-u user       : analyse experiment of a different user (default: yourself)"
}

. ../conf/conf_users.sh

#account=spnltune
account=none

while getopts "h?u:a:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    u)  USERexp=$OPTARG
        ;;
    a)  account=$OPTARG
        ;;
    esac
done
shift $((OPTIND-1))

if [ "$#" -lt 1 ]; then
   usage 
   exit 0
fi
if [ "$#" -eq 2 ]; then
   USERexp=$2
fi

OUT=/esnas/scratch/$USER/ecearth3-post/tmp
mkdir -p $OUT
JOBFILE=$OUT/ts-${1}.job

LOG=/esnas/scratch/$USER/ecearth3-post/log
mkdir -p $LOG

NPROCS=1

echo "Launching timeseries analysis for experiment $1 of user $USERexp"

#sed -i "s/<USERexp>/$USERexp/" $OUT/header.job
sed "s/<EXPID>/$1/" < $SCRIPTDIR/header_$MACHINE.tmpl > $JOBFILE
sed -i "s/<ACCOUNT>/$account/" $JOBFILE
sed -i "s/<USERme>/$USERme/" $JOBFILE
sed -i "s/<JOBID>/ts/" $JOBFILE
sed -i "s/<JOBHOST>/$JOBHOST/" $JOBFILE
sed -i "s/<NPROCS>/$NPROCS/" $JOBFILE
sed -i 's#<LOG>#'$LOG'#' $JOBFILE
sed -i 's#<ECE3POST_ROOT>#'${ECE3POST_ROOT}'#' $JOBFILE

echo ../timeseries/timeseries.sh $1 $USERexp >> $JOBFILE

cat $JOBFILE

[ "$JOBHOST" == "" ] && nodelist="" || nodelist="-w $JOBHOST"
ret=`sbatch $nodelist $JOBFILE`

echo "sbatch return code: $?"
echo "sbatch return: $ret"
echo "logs will be in $LOG/ts_${1}_"`echo $ret | awk '{print $4}'`".{err,out}"

echo "current queue for your user:"
squeue -u $USER

