# California Snowpack Data Download

These simple perl scripts create tidy csv files from the California
from the usda.gov's website.

[http://www.wcc.nrcs.usda.gov/snow/](SNOTEL)

## INSTALLATION

There is no installation however you may need some additional 
perl libraries. Specifically:

* Text::CSV
* LWP::Simple

As an added convenience, there's a Makefile.PL which will perform
these installs for you. Simply run:

* perl Makefile.PL
* make

to ensure the appropriate libraries are installed.

## USAGE

* fetch_stations.pl - gathers up the station location information
* fetch_data.pl - using the station data generate the final csv's

## DESCRIPTION

### NOTE

> If ../stations.csv has not been created, you will want to run
  fetch_stations.pl before you attempt to run fetch_data.pl as
  it relies on that file to generate the proper URLs.

### RAW DATA FILES

Raw data files are housed in the subdirectory 'raw' when
fetch_data.pl is run. These files are tested for their age in
an attempt to determine whether new data should be downloaded
from the web or simply rebuild our csv's file from the existing
cache.  If you wish to force the download of a specific station
simply remove the stations datafile in this directory. Each 
station is given a specific code which can be looked up in the
../stations.csv file or on the web at:

[http://www.wcc.nrcs.usda.gov/nwcc/yearcount?network=sntl&state=CA&counttype=statelist](Stations List)

By default new data will not be downloaded until the raw
data file is greater than 24 hours old. You are welcome to 
change this by editing the fetch_data.pl file by hand.

### OUTPUT

The following files will be created:

* stations.csv
  * station - name fo the station
  * site_code - assigned site code by the usda
  * start - YYYY-MM-DD started to collect data
  * lat - latitude of station
  * lon - longitude
  * elev - elevation
  * county
  * huc_desc - [https://en.wikipedia.org/wiki/Hydrological_code](hydrological code) description
  * huc_code - hydrological code attributed to this station

* snow_water.csv
* temp_avg.csv
* temp_max.csv
* temp_min.csv
* precipitation.csv
* precipitation_inc.csv

The last 6 data files consist of the date column and the readings
for each station attributed to that date for each of the specific
measurement.

