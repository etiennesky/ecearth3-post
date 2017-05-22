#!/bin/bash


usage()
{
   echo "Usage: "`basename $0`" [-u user] [-a account] [-r resolution] exp year1 year2 [user]"
   echo "Do analysis of experiment exp in years year1 to year2 for a specific user (optional) and resolution,"
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

#OUT=$SCRATCH/ecearth3-post/tmp
OUT=/esnas/scratch/$USER/ecearth3-post/tmp
mkdir -p $OUT
JOBFILE=$OUT/postall-${1}.job

LOG=/esnas/scratch/$USER/ecearth3-post/log
mkdir -p $LOG

NPROCS=3

echo "Launcing post-processing for experiment $1 of user $USERexp, log will be in $LOG"

sed "s/<EXPID>/$1/" < $SCRIPTDIR/header_$MACHINE.tmpl > $JOBFILE
sed -i "s/<ACCOUNT>/$account/" $JOBFILE
sed -i "s/<Y1>/$2/" $JOBFILE
sed -i "s/<Y2>/$3/" $JOBFILE
sed -i "s/<USERme>/$USERme/" $JOBFILE
sed -i "s/<USERexp>/$USERexp/" $JOBFILE
sed -i "s/<JOBHOST>/$JOBHOST/" $JOBFILE
sed -i "s/<NPROCS>/$NPROCS/" $JOBFILE
sed -i 's#<LOG>#'$LOG'#' $JOBFILE
sed -i "s/<JOBID>/postall/" $JOBFILE

#ET here TODO add options for hiresclim2 (run it? grb vs. MMA?) and determine numprocs
echo echo Running hiresclim2 >>  $JOBFILE
echo ../hiresclim2/master_hiresclim.sh $1 $2 $3 $USERexp >>  $JOBFILE
#ET here TODO run EC-Mean, timeseries and amwg in parallel if NPROCS>1
echo echo Running EC-Mean >>  $JOBFILE
echo ../ECmean/EC-mean.sh $1 $2 $3 $USERexp >>  $JOBFILE
echo echo Running timeseries >>  $JOBFILE
echo ../timeseries/timeseries.sh $1 $USERexp >> $JOBFILE
#echo echo Running AMWG >>  $JOBFILE
#echo ./amwg_modobs.sh $1 $2 $3 $USERexp $res >> $JOBFILE
echo echo postall done!!! >>  $JOBFILE

cat $JOBFILE

[ "$JOBHOST" == "" ] && nodelist="" || nodelist="-w $JOBHOST"
ret=`sbatch $nodelist $JOBFILE`

echo "sbatch return code: $?"
echo "sbatch return: $ret"
echo "logs will be in $LOG/postall_${1}_"`echo $ret | awk '{print $4}'`".{err,out}"

echo "current queue for your user:"
squeue -u $USER

