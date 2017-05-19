use strict;
use warnings;
use lib '../blib/lib';
use lib '../blib/arch';
use Local::Stats qw/add new stat/;
use DDP;

my $code = sub { $_[0] = ['cnt', 'avg', 'min', 'max', 'sum'] };
new($code);

for (1..10) {
    add('m1', $_);
    add('m2', $_) if ($_ > 5); 
}


p my $h = stat();