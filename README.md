# California Snowpack Data (ca-snowpack)

Tidy California Snowpack Data (csv) from NOAA 

These scripts pull down snowpack data from the
[http://www.wcc.nrcs.usda.gov/snow/about.html](USDA)
and clean it up so that we can monitor changes in
the stations in single csv files.

## Output Files

* stations.csv - list of stations and related data

* snow_water.csv - snowpack water equivelant in inches
* precipitation.csv - precipitation in inches
* precipitation_inc.csv	 - precipitation increase in inches
* temp_min.csv - minimum daily temperature in degrees fahrenheit
* temp_avg.csv - average daily temperature in degrees fahrenheit
* temp_max.csv - max daily temperature in degrees fahrenheit

## Features

We've implemented a caching system that allows you to re-process
your data files without having to download new data each time.
This means that you can run these scripts as many times as you'd
like without putting a strain on your network or the remote 
collection.
