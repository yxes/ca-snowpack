#!/usr/bin/env perl
use strict;
use warnings;

use constant VERBOSE => 0; # change to 1 to look under the hood

# NOTE: all the final csv files will be created in our parent directory.

# raw data directory...
use constant RAW_DIR => 'raw/'; # it's relative to us.

# how many hours before we consider our raw data stale?
use constant STALE_HOURS => 24;

# name of the stations csv file... we'll tack on csv for you.
use constant STATIONS_FILE => 'stations';

# these will be appended with .csv and the order is important
#  as it coincides with the column names
use constant MEASUREMENTS => qw/snow_water precipitation temp_max
		                temp_min temp_avg precipitation_inc/;

# URL to retrieve raw data
use constant URL => 'http://www.wcc.nrcs.usda.gov/reportGenerator/view_csv/'.
                    'customSingleStationReport/daily/[CODE]:CA:SNTL%7Cid=%22%22%7'.
		    'Cname/POR_BEGIN,POR_END/WTEQ::value,PREC::value,TMAX::value,'.
		    'TMIN::value,TAVG::value,PRCP::value';

use Cwd 'abs_path';
use Text::CSV;
use LWP::Simple();

# CSV Initialization
my $csv = Text::CSV->new({binary => 1}) or
            die "cannot use CSV: ", Text::CSV->error_diag();
   $csv->eol("\r\n");

# PROCESS
#
# 1. Gather up the Codes (and names) from the stations.csv file
     my @codes = codes(); # (['name', code],['name', code]...)
#
# 2. Ensure we have current local copies of the raw data
     retrieve_data();
#
# 3. Process the raw data
     my $data = process_data();

#
# 4. Output the data into it's respective files
     output_data($data);
#
#

exit;

# Subroutines
#

# gimme a CODE and I'll return the location of the raw file
sub raw_filename { (abs_path($0) =~ /(.*\/)/)[0] . RAW_DIR . $_[0] . '.csv' }

# and again for the final filename but with the MEASUREMENT value
sub output_filename { (abs_path($0) =~ /(.*\/)/)[0] . '../' . $_[0] . '.csv' }

# returns array of [ NAME, CODE ]
sub codes {
    my @codes;
   {
      # we are taking advantage of the fact that the stations file is located
      # with all the other data files...
      open my $fh, "<:encoding(utf8)", output_filename(STATIONS_FILE) or
             die "can't read: ", output_filename(STATIONS_FILE), ": $!";

      my $count = 0;
      while (my $row = $csv->getline($fh)) {
	    ++$count && next unless $count; # skip the header
	    push(@codes, [$row->[0], $row->[1]]);
      }
   }

@codes
}

# TODO: we could improve on this by only downloading what we need...
sub retrieve_data {
    # do we need to download it or do we already have it?
    for my $code (map $_->[1], @codes) {
	my $filename = raw_filename($code);

	# if the file exists, is not empty and hasn't expired we'll continue
	next if (-e $filename && -s $filename && (-M $filename) * 24 < STALE_HOURS);

	# otherwise we'll download new data
	(my $url = URL) =~ s/\[CODE\]/$code/g;
	warn "Downloading URL: $url" if VERBOSE;
	LWP::Simple::mirror($url, $filename);
        sleep(1); # play nice... don't want to slam the nice people who are sharing data
    }
}

# data = {
#     MEASUREMENT => {      | i.e. snow_water
#         DATE => {         | i.e. 20150620 [YYYYMMDD]
#             CODE => value | i.e. 304 => 2.3 (code is station code)
#        }
#     }
# }
#
sub process_data {
    my $data;

    for my $station (@codes) {
	my ($name, $code) = @$station;
        warn "Processing: ", $name if VERBOSE;

	open my $raw_fh, "<:encoding(utf8)", raw_filename($code) or
	    die "can't read: ", raw_filename($code), ": $!";

	    my $row_count = 0;
	    while (<$raw_fh>) {
		  chomp;
		  s/#.*//; # strip off comments
		  next unless $_; # skip blank lines

		  $csv->parse($_);
		  my @cols = $csv->fields;

		  if (!$row_count++) { # header!
		     die "Error in $name [$code]: headers are off.."
		         if (@cols < (MEASUREMENTS) + 1); # MEASUREMENTS + DATE COLUMN
		     next; # skip the header
		  }

		  (my $date = $cols[0]) =~ s/\D//g; # YYYY-MM-DD ==> YYYYMMDD

		  my $col_count = 1;
		  for my $measurement (MEASUREMENTS) {
		      # ensure we have our layout correct
		        $data->{$measurement} = {} unless $data->{$measurement};
		        $data->{$measurement}->{$date} = {} unless $data->{$measurement}->{$date};
		      
		      $data->{$measurement}->{$date}->{$code} = $cols[$col_count++];
		  }
	  }
    }

$data
}

sub output_data {
    my($data) = @_;

use Data::Dumper;

    for (keys %$data) {
	warn "Creating File: ", output_filename($_), "..." if VERBOSE;

	open my $output_fh, ">:encoding(utf8)", output_filename($_) or
	    die "can't write: ", output_filename($_), ": $!";

	# header - DATE | station_123 | station_456 | station_567 ...
	$csv->print($output_fh, ['date', map 'station_'. $_, sort {$a <=> $b} map $_->[1], @codes]);

	my $measurement = $data->{$_}; # HASH of measurement data | date => { code => value }

	for (sort {$a <=> $b} keys %$measurement) { # sorted dates YYYYMMDD
	    my $date = $measurement->{$_};
	    my @row = ( join('-', unpack('A4A2A2', $_) )); # convert to YYYY-MM-DD
	    #for my $code (sort {$a <=> $b} keys %$date) {
	    for my $station (@codes) {
		my($name, $code) = @$station;
	        push(@row, $date->{$code} || '');
	    }
	    $csv->print($output_fh, \@row);
	}
    }
}
