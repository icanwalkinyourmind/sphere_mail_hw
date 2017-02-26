#!/usr/bin/perl -w
use strict;
use warnings;
sub run{
    my ($str, $substr) = @_;
    my $num = 0;
    my $index = 0;
    
    while ("loop") {
        $index = index ($str, $substr, $index);
        last if ($index == -1);
        $index += length($substr);
        $num++
    }
    
    print "$num\n";
}

1;
