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

OUT=$SCRATCH/tmp
mkdir -p $OUT

if [ "$#" -lt 3 ]; then
   usage
   exit 0
fi

if [ "$#" -ge 4 ]; then
   USERexp=$4
fi

sed "s/<EXPID>/$1/" < $SCRIPTDIR/header_$MACHINE.tmpl > $OUT/amwg.job
sed -i "s/<USERme>/$USERme/" $OUT/amwg.job
sed -i "s/<ACCOUNT>/$account/" $OUT/amwg.job
sed -i "s/<JOBID>/amwg/" $OUT/amwg.job

echo ./amwg_modobs.sh $1 $2 $3 $USERexp $res >> $OUT/amwg.job

qsub $OUT/amwg.job
qstat -u $USERme
