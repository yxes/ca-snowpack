use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'water_ca',
    AUTHOR       => 'Stephen D. Wells (yxes@cpan.org)',
    ABSTRACT     => 'install libraries used to fetch the latest snowpack data from California',
    PREREQ_PM    => {
                     'Cwd' => '3.48',
                     'Text::CSV' => '1.33',
		     'LWP::Simple' => '6.13'
                    },
);
