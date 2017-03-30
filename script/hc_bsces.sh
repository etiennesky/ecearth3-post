#!/bin/bash


usage()
{
   echo "Usage: "`basename $0`" [-a account] [-u user] exp year1 year2 [user]"
   echo "Run hiresclim postprocessing of experiment exp in years year1 to year2 for a specific user (optional)"
   echo "Options are:"
   echo "-a account    : specify a different special project for accounting (default: spnltune)"
   echo "-u user       : analyse experiment of a different user (default: yourself)"
}

. $HOME/ecearth3/post/conf/conf_users.sh

#set -uxe

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

if [ "$#" -lt 3 ]; then
   usage
   exit 0
fi

if [ "$#" -ge 4 ]; then
   USERexp=$4
fi

#OUT=$SCRATCH/ecearth3-post/tmp
OUT=/esnas/scratch/etourign/ecearth3-post/tmp
mkdir -p $OUT
JOBFILE=$OUT/hc-${1}.job

LOG=/esnas/scratch/etourign/ecearth3-post/log
mkdir -p $LOG

NPROCS=3

echo "Launcing hiresclim for experiment $1 of user $USERexp, log will be in $LOG"

sed "s/<EXPID>/$1/" < hc_bsces.tmpl > $JOBFILE
sed -i "s/<ACCOUNT>/$account/" $JOBFILE
sed -i "s/<Y1>/$2/" $JOBFILE
sed -i "s/<Y2>/$3/" $JOBFILE
sed -i "s/<USERme>/$USERme/" $JOBFILE
sed -i "s/<USERexp>/$USERexp/" $JOBFILE
sed -i "s/<JOBHOST>/$JOBHOST/" $JOBFILE
sed -i "s/<NPROCS>/$NPROCS/" $JOBFILE
sed -i 's#<LOG>#'$LOG'#' $JOBFILE

cat $JOBFILE

[ "$JOBHOST" == "" ] && nodelist="" || nodelist="-w $JOBHOST"
ret=`sbatch $nodelist $JOBFILE`

echo "sbatch return code: $?"
echo "sbatch return: $ret"
echo "logs will be in $LOG/hc_${1}_"`echo $ret | awk '{print $4}'`".{err,out}"

echo "current queue for your user:"
squeue -u $USER

