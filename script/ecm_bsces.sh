#!/bin/bash

usage()
{
   echo "Usage: "`basename $0`" [-a account] [-u user] exp year1 year2 [user]"
   echo "Compute global averages (EC-mean) for experiment exp in years from year1 to year2 of user (optional)"
   echo "Options are:"
   echo "-a account    : specify a different special project for accounting (default: spnltune)"
   echo "-u user       : analyse experiment of a different user (default: yourself)"
}

. $HOME/ecearth3/post/conf/conf_users.sh

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
if [ "$#" -eq 4 ]; then
   USERexp=$4
fi

#OUT=$SCRATCH/ecearth3-post/tmp
OUT=/esnas/scratch/$USER/ecearth3-post/tmp
mkdir -p $OUT
JOBFILE=$OUT/ecm-${1}.job

LOG=/esnas/scratch/$USER/ecearth3-post/log
mkdir -p $LOG

echo "Launching EC-mean analysis for experiment $1 of user $USERexp"

sed "s/<EXPID>/$1/" < $SCRIPTDIR/header_bsces.tmpl > $JOBFILE
sed -i "s/<ACCOUNT>/$account/" $JOBFILE
sed -i "s/<USERme>/$USERme/" $JOBFILE
sed -i "s/<JOBID>/ecm/" $JOBFILE
sed -i "s/<JOBHOST>/$JOBHOST/" $JOBFILE
sed -i 's#<LOG>#'$LOG'#' $JOBFILE

echo ../ECmean/EC-mean.sh $1 $2 $3 $USERexp >>  $JOBFILE

cat $JOBFILE

[ "$JOBHOST" == "" ] && nodelist="" || nodelist="-w $JOBHOST"
ret=`sbatch $nodelist $JOBFILE`

echo "sbatch return code: $?"
echo "sbatch return: $ret"
echo "logs will be in $LOG/ecm_${1}_"`echo $ret | awk '{print $4}'`".{err,out}"

echo "current queue for your user:"
squeue -u $USER



