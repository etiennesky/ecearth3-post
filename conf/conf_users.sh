export USER0=ccjh    # Who owns the scripts
export USERme=ccjh   # This is the user calling the scripts
if [[ -z $USERexp ]]; then
   export USERexp=ccjh # User whose experiments we are going to process
fi 

########################
export MACHINE=cca   # Name of this machine to choose conf files
export CONFDIR=/home/ms/it/$USER0/ecearth3/post/conf # Where all config files are
export SCRIPTDIR=/home/ms/it/$USER0/ecearth3/post/script # Where all scripts files are
