#!/bin/bash

. $HOME/ecearth3/post/conf/conf_users.sh

# load required modules
module load NCO netCDF Python CDO NCL #CDFTOOLS matplotlib
#module load NCL/6.2.1-foss-2015a

# Where to find EMoP:
export EMOP_DIR="/home/Earth/$USER0/ecearth3/post/amwg"

# Name of current conf (same as this file name conf_<EMOP_CONF>.csh):
export EMOP_CONF="bsces"

# Where to find raw EC-Earth output (should contain "ifs" and "nemo" sub-directories...)
# => use "<RUN>" for run name:
#export ECEARTH_OUT_DIR="/nobackup/rossby17/rossby/joint_exp/swedens2/<RUN>"

# Root path to a temporary filesystem:
export TMPDIR_ROOT="${SCRATCH}/ecearth3-post/tmp/timeseries"

# *** POST_DIR: where to store post-processed EC-Earth files generated by XXXX
#               With <RUN> replacing the name of your experiment:
#export POST_DIR="/nobackup/vagn2/john/tmp/post/<RUN>"
export POST_DIR="/esnas/scratch/etourign/ecearth3-post/exp/<RUN>/post"

# *** EMOP_CLIM_DIR: where to store the AMWG-friendly climatology files:
#export EMOP_CLIM_DIR="/esnas/scratch/etourign/ecearth3-post/amwg"
#TODO do all temporary stuff in ncarize_pd.sh in $TMPDIR_ROOT and the ncopy results to /esnas
export EMOP_CLIM_DIR="$SCRATCH/ecearth3-post/amwg"


# *** DIR_EXTRA:
export DIR_EXTRA="${EMOP_DIR}/data"


# AMWG NCAR data?
#export NCAR_DATA="/perm/ms/it/$USER0/ecearth3/amwg_data"
#export DATA_OBS="${NCAR_DATA}/obs_data_5.5"
export NCAR_DATA="/esnas/scratch/etourign/svn/ncar"
export DATA_OBS="${NCAR_DATA}/obs_data_20140804"

#export NEMOCONFIG="ORCA1L46"
export NEMOCONFIG=ORCA025L75
export NEMO_MESH_DIR=/esnas/scratch/etourign/ecearth3-post/data/nemo/$NEMOCONFIG


# Where to store time-series produced by script
export DIR_TIME_SERIES="${EMOP_CLIM_DIR}/timeseries"

# About web page, on remote server host:
#     =>  set RHOST="" to disable this function...
export RHOST=""
export RUSER=""
export WWW_DIR_ROOT=""


############################
# About required software   #
############################

# support for GRIB_API?
# Set the directory where the GRIB_API tools are installed
# Note: cdo had to be compiled with GRIB_API support for this to work
# This is only required if your highest level is above 1 hPa,
# otherwise leave GRIB_API_BIN empty (or just comment the line)!
#export GRIB_API_BIN="/home/john/bin"

# The CDFTOOLS set of executables should be found into:
export CDFTOOLS_BIN="/usr/local/apps/cdftools/3.0/bin"

# The scrip "rebuild" as provided with NEMO (relies on flio_rbld.exe):
export RBLD_NEMO="/perm/ms/it/$USER0/ecearth3/rebuild_nemo/rebuild_nemo"

#python
export PYTHON="python"

#cdo
export cdo="cdo"

######################################################
# List of stuffs needed for script NCARIZE_b4_AMWG.sh
######################################################

# In case of coupled simulation, for ocean fields, should we extrapolate
# sea-values over continents for cleaner plots?
#    > will use DROWN routine of SOSIE interpolation package "mask_drown_field.x"
#i_drown_ocean_fields 1 ; # 1  > do it / 0  > don't

export i_drown_ocean_fields="1" ; # 1  > do it / 0  > don't
export MESH_MASK_ORCA="mask.nc"

export SOSIE_DROWN_EXEC=""

# Ocean fields:
#export LIST_V_2D_OCE="sosstsst iiceconc"
export LIST_V_2D_OCE=""


# 2D Atmosphere fields (ideally):
#export LIST_V_2D_ATM="ps \
               #msl \
               #uas \
               #vas \
               #tas \
               #e stl1 \
               #tcc totp cp lsp ewss nsss sshf slhf ssrd strd \
               #ssr str tsr ttr tsrc ttrc ssrc strc lcc mcc hcc \
               #tcwv tclw tciw fal"
#
# Those we have:
export LIST_V_2D_ATM="msl uas vas tas e sp \
    		tcc totp cp lsp ewss nsss sshf slhf ssrd strd \
    		ssr str tsr ttr tsrc ttrc ssrc strc lcc mcc hcc \
    		tcwv tclw tciw fal"


# 3D Atmosphere fields (ideally):
#export LIST_V_3D_ATM="q r t u v z"

# Those we have:
export LIST_V_3D_ATM="q t u v z"
#export LIST_V_3D_ATM=""

# ET HERE add this flag elsewhere
# ET HERE fix nemo hiresclim first!
do_ocean=false

do_trans=false
