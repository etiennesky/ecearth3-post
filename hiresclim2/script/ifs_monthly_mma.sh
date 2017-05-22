#!/bin/bash
set -ex

#reading args
expname=$1
year=$2

#usage
if [ $# -lt 2 ]
then
  echo "Usage:   ./ifs_monthly_mmo.sh EXP YEAR"
  echo "Example: ./ifs_monthly_mmo.sh io01 1990"
  exit 1
fi

#ET HERE remove loading of config.sh
if [ $# -ne 3 ]; then
# definition of variables is done in config.sh
. ../config.sh
else
. $3
fi

#go to temp dir
cd $TMPDIR

#where to get the files
#IFSRESULTS=$BASERESULTS/Output_$year/IFS
IFSRESULTS=$BASERESULTS
NPROCS=${IFS_NPROCS}

echo $OUTDIR0
# where to save (archive) the results
OUTDIR=$OUTDIR0/mon/Post_$year
echo $OUTDIR
mkdir -p $OUTDIR || exit -1

# output filename root
out=$OUTDIR/${expname}_${year}

#untar MMA* file
#cd $OUTDIR
for f in $IFSRESULTS/MMA_${expname}_????????_fc*_${year}????-${year}????.tar ; do tar xvf $f ; done
for f in MMA_${expname}_??_${year}??.nc.gz ; do gunzip $f ; done

# ICMSH
for m1 in $(seq 1 $NPROCS 12)
do
   for m in $(seq $m1 $((m1+NPROCS-1)) )
   do
      ym=$(printf %04d%02d $year $m)
      #gunzip MMA_${expname}_SH_${ym}.nc.gz
      #$cdo -b F64 splitvar -sp2gpl \
      $cdo -b F32 splitvar -sp2gpl \
         -setdate,$year-$m-01 -settime,00:00:00 \
         $TMPDIR/MMA_${expname}_SH_${ym}.nc icmsh_${ym}_ &

   done
   wait
done

for v2 in t u v z #lnsp
do
   v1="${v2^^}"
   rm -f ${out}_${v2}.nc
   $cdozip -r -R chname,${v1},${v2} -cat "icmsh_${year}??_${v1}.nc" ${out}_${v2}.nc
done

#part on surface pressure
#$cdo chcode,152,134 ${out}_lnsp.nc temp_lnsp.nc
#$cdo -t $ecearth_table exp temp_lnsp.nc ${out}_sp.nc
#rm temp_lnsp.nc


# ICMGG
for m1 in $(seq 1 $NPROCS 12)
do
   for m in $(seq $m1 $((m1+NPROCS-1)) )
   do
      ym=$(printf %04d%02d $year $m)
      #$cdo -b F64 setdate,$year-$m-01 -settime,00:00:00 \
      $cdo -b F32 setdate,$year-$m-01 -settime,00:00:00 \
         $TMPDIR/MMA_${expname}_GG_${ym}.nc icmgg_${ym}.nc &

   done
   wait
done

rm -f icmgg_${year}.nc
$cdo cat icmgg_${year}??.nc icmgg_${year}.nc

#rename vars: build a list of rename pairs and call ncrename once
rename_str=""
vars1=(U10M V10M T2M D2M var78 var79)
vars2=(uas vas tas tds tclw tciw)
for (( i = 0 ; i < ${#vars1[@]} ; i++ )) 
do
#   ncrename -v $v1,$v2 icmgg_${year}.nc
   rename_str="${rename_str} -v ${vars1[$i]},${vars2[$i]}"
done
vars2="ci sstk sd tcc lcc mcc hcc tcwv msl q fal ro sf lsp cp e ssr str sshf ssrd strd slhf tsr ttr ewss nsss ssrc strc tsrc ttrc"
for v2 in $vars2
do
   v1="${v2^^}"
#   ncrename -v $v1,$v2 icmgg_${year}.nc
   rename_str="${rename_str} -v $v1,$v2"
done
ncrename $rename_str icmgg_${year}.nc


# extract variables which do not require any calculations
$cdozip -r -R splitvar \
   -selvar,uas,vas,tas,ci,sstk,sd,tds,tcc,lcc,mcc,hcc,tclw,tciw,tcwv,msl,q,fal \
   icmgg_${year}.nc ${out}_


# post-processing timestep in seconds
# pptime cannot be determined from the MMA files and must be set manually
pptime=$PPTIME

# precip and evap and runoff in kg m-2 s-1
$cdozip -R -r mulc,1000 -divc,$pptime -selvar,ro \
   icmgg_${year}.nc ${out}_ro.nc
$cdozip -R -r mulc,1000 -divc,$pptime -selvar,sf \
   icmgg_${year}.nc ${out}_sf.nc
$cdo expr,"totp=1000*(lsp+cp)/$pptime" \
   icmgg_${year}.nc tmp_totp.nc
$cdozip -r -R copy tmp_totp.nc ${out}_totp.nc

#$cdozip -r -R mulc,1000 -divc,$pptime -selvar,e \
#   icmgg_${year}.nc ${out}_e.nc
$cdozip -r -R splitvar -mulc,1000 -divc,$pptime \
 -selvar,e,lsp,cp icmgg_${year}.nc ${out}_
$cdo -R fldmean \
   -expr,"pme=1000*(lsp+cp+e)/$pptime" icmgg_${year}.nc tmp_pme.nc
$cdozip -r copy tmp_pme.nc ${out}_pme.nc

# divide fluxes by PP timestep
$cdozip -r -R splitvar -divc,$pptime \
   -selvar,ssr,str,sshf,ssrd,strd,slhf,tsr,ttr,ewss,nsss,ssrc,strc,tsrc,ttrc \
   icmgg_${year}.nc ${out}_

# net SFC and TOA fluxes
$cdo -R fldmean \
   -expr,"snr=(ssr+str+slhf+sshf)/$pptime" icmgg_${year}.nc tmp_snr.nc
$cdozip -r copy tmp_snr.nc ${out}_snr.nc
$cdo -R fldmean \
   -expr,"tnr=(tsr+ttr)/$pptime" icmgg_${year}.nc tmp_tnr.nc
$cdozip -r copy tmp_tnr.nc ${out}_tnr.nc

# fix units, ugly hack
for v in ci fal tcc lcc mcc hcc ; do ncatted -a units,${v},c,c,'0-1' ${out}_${v}.nc ; done
for v in e lsp cp ro sf ; do ncatted -a units,${v},m,c,'kg m-2 s-1' ${out}_${v}.nc ; done
for v in pme totp ; do ncatted -a units,${v},c,c,'kg m-2 s-1' ${out}_${v}.nc ; done
for v in ewss nsss ; do ncatted -a units,${v},m,c,'N m-2' ${out}_${v}.nc ; done
for v in sd ; do ncatted -a units,${v},c,c,'m' ${out}_${v}.nc ; done
for v in ssr str sshf ssrd strd slhf tsr ttr ssrc strc tsrc ttrc ; do \
    ncatted -a units,${v},m,c,'W m-2' ${out}_${v}.nc ; done
for v in snr tnr ; do ncatted -a units,${v},c,c,'W m-2' ${out}_${v}.nc ; done
for v in tclw tciw ; do ncatted -a units,${v},c,c,'kg m-2' ${out}_${v}.nc ; done
for v in tcwv ; do ncatted -a units,${v},m,c,'kg m-2' ${out}_${v}.nc ; done

# fix long_name
for v in pme totp ; do ncatted -a long_name,${v},c,c,'Total precipitation' ${out}_${v}.nc ; done

# change file suffices
( cd $OUTDIR ; for f in $(ls *.nc4); do mv $f ${f/.nc4/.nc}; done )

rm $TMPDIR/*.nc
cd -
rmdir $TMPDIR
