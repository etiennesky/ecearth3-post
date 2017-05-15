The ecearth3-post suite is set of scripts used to post-process EC-Earth3 output.

These scripts have been adapted from the scripts found on CCA at /perm/ms/it/ccjh/ecearth3/post for the BSC-ES FAT nodes (gustafson, etc.).

ecearth3-post consists of several independent tools:

- hiresclim2 which creates monthly average files from IFS raw grib files or MMO files
- ECmean which is used to compute several values such as energy budget and temperature, averaged over the globe and a given timeseries
- timeseries which prepares BaraKuda-style timeseries plots of some atmospheric variables
- AMWG, still unsupported

For more details please read the docs in doc/EC-Earth_postprocessing_scripts.pdf which apply to running the suite on CCA.

In order to install the tool clone this repository and move it to $HOME/ecearth3/post like this

```
mkdir -p $HOME/tmp && cd $HOME/tmp
git clone https://earth.bsc.es/gitlab/cp/ecearth3-post.git
mkdir $HOME/ecearth3
mv ecearth3-post $HOME/ecearth3/post
```

The first tool to run is hiresclim2. Before running hiresclim2 you must define the location of the EC-Earth output files following this example:

```
mkdir -p /esarchive/exp/ecearth/a0ln/ecearth3-post
ln -s /esarchive/exp/ecearth/a0ln/original_files/19900101/fc0/outputs/ /esarchive/exp/ecearth/a0ln/ecearth3-post/
```

If the EC-Earth output files for IFS are the raw grib files instead of MMA files generated by the auto-ecearth3 POST job, you must edit the hiresclim2/master_hiresclim.sh file like this:

```
ifs_monthly=1
ifs_monthly_mma=0
```

Next you submit the hiresclim script to the FAT nodes like this:

```
cd $HOME/ecearth3/post
./hc_bsces.sh <expid> <year1> <year2>
for example: 
./hc_bsces.sh a0ln 1990 1991
```

Once it is finished you can run the other tools like this:

```
./ecm_bsces.sh <expid> <year1> <year2>
./timeseries_bsces.sh <expid> <year1> <year2>
```

The hiresclim monthly files will be in ```/esarchive/exp/ecearth/<expid>/ecearth3-post/post/mon```

The ECmean table files will be in ```/esarchive/exp/ecearth/<expid>/ecearth3-post/diag/table```

The timeseries plots can be viewed in ```/esarchive/exp/ecearth/<expid>/ecearth3-post/diag/timeseries/atmosphere/index.html```


