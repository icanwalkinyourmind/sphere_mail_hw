#!/usr/bin/perl

use strict;
use warnings;

sub encode {
    my ($str, $key) = @_;
    my $encoded_str = '';

    foreach (split //, $str){
        my $ord = (ord($_) + $key) % 127;
        $encoded_str .= chr($ord);
    }

    print "$encoded_str\n";
}


sub decode {
    my ($encoded_str, $key) = @_;
    my $str = '';

    foreach (split //, $encoded_str){
        my $ord = (ord($_) - $key) % 127;
        $str .= chr($ord);
    }

    print "$str\n";
}

1;