#!/usr/bin/env perl
use strict;
use warnings;

use constant OUTPUT_FILENAME => 'stations.csv';
use constant HEADERS => qw/station site_code start lat lon elev county huc_desc huc_code/;

use constant URL => 'http://www.wcc.nrcs.usda.gov/nwcc/yearcount?state=CA&counttype=statelist';
use constant MONTHS =>
    qw/January Februrary March April May June July August September October November December/;

use Cwd 'abs_path';
use LWP::Simple();
use Text::CSV;

my $page = LWP::Simple::get(URL);

my($table) = ($page =~ /scanReportHeaderBlue(.*)<\/table>/s);

my @stations; # name | code | start [YYYY-MM-01] | lat | lon | evel | county | huc_desc | huc

my $count = 0;
for my $row (split /<\/tr>\s*<tr\s*>/, $table) {
    ++$count && next unless $count; # skip the header row
    my @station;
    my @values = ($row =~ />\s*(.*?)\s*<\/td>/g)[0 .. 9];

    @station[0,1] = split /\s+\(/, $values[2]; # NAME, CODE
    $station[1] =~ s/\)\s*$//;                 # Just the code
    $station[2] = $values[4];                  # START
    my $month = 0;
    for (MONTHS) {
	$month++;
	next unless $station[2] =~ /$_/;
        $station[2] =~ s/$_/$month.'-01'/e;
	last;
    }

    @station[3..6] = @values[5..8]; # LAT | LON | ELEV | COUNTY

    @station[7,8] = split /\s+\(/, $values[9];  # HUC DESC | HUC CODE
    $station[8] =~ s/\)\s*$//;		        # Just the huc

    push(@stations, [@station]);
}

# OUTPUT A CSV FILE

(my $parent_path = abs_path($0)) =~ s/(.*\/).*?\/.*?$/$1/;

my $csv = Text::CSV->new({binary => 1}) or die "can't use CSV: ".Text::CSV->error_diag();
   $csv->eol("\r\n");

open my $fh, ">:encoding(utf8)", $parent_path. OUTPUT_FILENAME or 
    die "can't create: ", $parent_path. OUTPUT_FILENAME, ": $!";
   $csv->print($fh, [HEADERS]);
   $csv->print($fh, $_) for @stations;

warn "done.\n";
