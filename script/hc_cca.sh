#!/bin/bash

usage()
{
   echo "Usage: hc.sh [-a account] [-u user] exp year1 year2 [user]"
   echo "Run hiresclim postprocessing of experiment exp in years year1 to year2 for a specific user (optional)"
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

if [ "$#" -lt 3 ]; then
   usage
   exit 0
fi

if [ "$#" -ge 4 ]; then
   USERexp=$4
fi

OUT=$SCRATCH/tmp
mkdir -p $OUT

sed "s/<EXPID>/$1/" < hc.tmpl > $OUT/hc.job
sed -i "s/<ACCOUNT>/$account/" $OUT/hc.job
sed -i "s/<Y1>/$2/" $OUT/hc.job
sed -i "s/<Y2>/$3/" $OUT/hc.job
sed -i "s/<USERme>/$USERme/" $OUT/hc.job
sed -i "s/<USERexp>/$USERexp/" $OUT/hc.job

qsub $OUT/hc.job
qstat -u $USERme
