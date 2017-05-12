The ecearth3-post suite is set of scripts used to post-process EC-Earth3 output.

These scripts have been adapted from the scripts found on CCA at /perm/ms/it/ccjh/ecearth3/post for the BSC-ES FAT nodes (gustafson, etc.).

ecearth3-post consists of several independent tools:

- hiresclim2 creates monthly average files from IFS raw grib files or MMO files
- ECmean is used to compute several values such as energy budget and temperature, averaged over the globe and a given timeseries
- timeseries prepares BaraKuda-style timeseries plots of some atmospheric variables
- AMWG, still being tested

For more details please read the docs in doc/EC-Earth_postprocessing_scripts.pdf which apply to running the suite on CCA.

In order to install the tool clone this repository and move it to $HOME/ecearth3/post like this

cd $HOME/tmp
git clone https://earth.bsc.es/gitlab/cp/ecearth3-post.git
mkdir $HOME/ecearth3
mv ecearth3-post $HOME/ecearth3/post

The first tool to run is highresclim2. Before running hiresclim2 you must define the location of the EC-Earth output files following this example:

mkdir -p /esarchive/exp/ecearth/a0ez/ecearth3-post
ln -s /esarchive/exp/ecearth/a0ez/original_files/19500101/fc0/outputs/ /esarchive/exp/ecearth/a0ez/ecearth3-post/outputs/

Next you run the hiresclim script as a batch script like this:

cd $HOME/ecearth3/post
./hc_bsces.sh <expid> <year1> <year2>
for example: 
./hc_bsces.sh a0ln 1990 1991

Once it is finished you can run the other tools like this:

./ecm_bsces.sh <expid> <year1> <year2>
./timeseries_bsces.sh <expid> <year1> <year2>

The hiresclim monthly files will be in /esarchive/exp/ecearth/<expid>/ecearth3-post/post/mon
The ECmean table files will be in /esarchive/exp/ecearth/<expid>/ecearth3-post/diag/table
The timeseries plots can be viewed in /esarchive/exp/ecearth/<expid>/ecearth3-post/diag/timeseries/atmosphere/index.html


