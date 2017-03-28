#!/bin/bash

usage()
{
   echo "Usage: ecm.sh [-a account] [-u user] exp year1 year2 [user]"
   echo "Compute global averages (EC-mean) for experiment exp in years from year1 to year2 of user (optional)"
   echo "Options are:"
   echo "-a account    : specify a different special project for accounting (default: spnltune)"
   echo "-u user       : analyse experiment of a different user (default: yourself)"
}

. $HOME/ecearth3/post/conf/conf_users.sh

account=spnltune

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

OUT=$SCRATCH/tmp
mkdir -p $OUT

if [ "$#" -lt 1 ]; then
   usage 
   exit 0
fi
if [ "$#" -eq 4 ]; then
   USERexp=$4
fi

echo "Launched EC-mean analysis for experiment $1 of user $USERexp"

sed "s/<EXPID>/$1/" < $SCRIPTDIR/header_$MACHINE.tmpl > $OUT/ecm.job
sed -i "s/<ACCOUNT>/$account/" $OUT/ecm.job
sed -i "s/<USERme>/$USERme/" $OUT/ecm.job
sed -i "s/<JOBID>/ecm/" $OUT/ecm.job

echo ./EC-mean.sh $1 $2 $3 $USERexp >>  $OUT/ecm.job

qsub $OUT/ecm.job
qstat -u $USERme


