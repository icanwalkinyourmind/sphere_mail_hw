#!/usr/bin/perl -w
use strict;
use warnings;

sub run{
    @_ = sort {$a <=> $b} @_;
    my $min = $_[0];
    my $max = $_[-1];
    print "$min, $max\n";
}

1;
