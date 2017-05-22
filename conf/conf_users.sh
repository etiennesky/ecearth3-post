export USER0=$USER    # Who owns the scripts
export USERme=$USER   # This is the user calling the scripts
if [[ -z "${USERexp-}" ]]; then
   export USERexp=$USER # User whose experiments we are going to process
fi 

########################
export MACHINE=bsces  # Name of this machine to choose conf files
#export CONFDIR=/home/Earth/$USER0/ecearth3/post/conf # Where all config files are
#export SCRIPTDIR=/home/Earth/$USER0/ecearth3/post/script # Where all scripts files are
export ECE3POST_ROOT=`readlink -f $(dirname $BASH_SOURCE)"/.."`
export CONFDIR=${ECE3POST_ROOT}/conf # Where all config files are
export SCRIPTDIR=${ECE3POST_ROOT}/script # Where all scripts files are

#ET HERE set this somewhere when running the scripts standalone
export IFS_NPROCS=3
export NEMO_NPROCS=3

# name of host to run on (only for MACHINE=bsces), or set JOBHOST="" to let the queue manager choose
# choose one of amdahl, moore, gustafson for the entire post-processing suite
# since some temporary files are stored on the local scratch folder
#JOBHOST=""
#JOBHOST=gustafson
JOBHOST=moore

#local scratch folder, please make sure this doesn't conflict with your setup
export SCRATCH=/scratch/`id -gn`/${USER}
