#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use v5.010;
use feature 'state';

my $file;
GetOptions("file=s" => \$file);

open (my $fh, '>', $file);
my $int_count = 0;
my ($n_of_str, $len_of_str) = (0, 0);

sub print_res {
    my $res =  sprintf "%d %d %d\n", $len_of_str, $n_of_str, $len_of_str/$n_of_str;
    print "$res";
    close ($fh);
}


$SIG{INT} = sub {
    print STDERR "Double Ctrl+C for exit" if $int_count == 0;
    $int_count++;
    if ( $int_count == 2) {
        print_res();
        exit;
    }
};

say "Get ready";

while (<STDIN>) {
    $int_count = 0;
    print $fh $_;
    $n_of_str++;
    chomp;
    $len_of_str += length $_;
}

print_res();