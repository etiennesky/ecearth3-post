#!/bin/bash

usage()
{
   echo "Usage: "`basename $0`" [-u user] [-a account] [-r resolution] exp year1 year2 [user]"
   echo "Do AMWG analysis of experiment exp in years year1 to year2 for a specific user (optional) and resolution,"
   echo "where resolution is N128, N256 etc. (N128=default)"
   echo "Options are:"
   echo "-a account    : specify a different special project for accounting (default: spnltune)"
   echo "-u user       : analyse experiment of a different user (default: yourself)"
   echo "-u resolution : resolution (default: N128)"
}

. $HOME/ecearth3/post/conf/conf_users.sh

#account=spnltune
account=none

res=N128

while getopts "h?u:a:r:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    u)  USERexp=$OPTARG
        ;;
    a)  account=$OPTARG
        ;;
    r)  res=$OPTARG
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

OUT=/esnas/scratch/$USER/ecearth3-post/tmp
mkdir -p $OUT
JOBFILE=$OUT/amwg-${1}.job

LOG=/esnas/scratch/$USER/ecearth3-post/log
mkdir -p $LOG

NPROCS=1

echo "Launching AMWG analysis for experiment $1 of user $USERexp"

sed "s/<EXPID>/$1/" < $SCRIPTDIR/header_$MACHINE.tmpl > $JOBFILE
sed -i "s/<USERme>/$USERme/" $JOBFILE
sed -i "s/<ACCOUNT>/$account/" $JOBFILE
sed -i "s/<JOBID>/amwg/" $JOBFILE
sed -i "s/<JOBHOST>/$JOBHOST/" $JOBFILE
sed -i "s/<NPROCS>/$NPROCS/" $JOBFILE
sed -i 's#<LOG>#'$LOG'#' $JOBFILE

echo ../amwg/amwg_modobs.sh $1 $2 $3 $USERexp $res >> $JOBFILE

cat $JOBFILE

[ "$JOBHOST" == "" ] && nodelist="" || nodelist="-w $JOBHOST"
ret=`sbatch $nodelist $JOBFILE`

echo "sbatch return code: $?"
echo "sbatch return: $ret"
echo "logs will be in $LOG/amwg_${1}_"`echo $ret | awk '{print $4}'`".{err,out}"

sleep 2
echo "current queue for your user:"
squeue -u $USER

