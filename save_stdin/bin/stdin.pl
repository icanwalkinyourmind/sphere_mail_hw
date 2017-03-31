#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use v5.010;
use feature 'state';

say "Get ready";
my $file;
GetOptions("file=s" => \$file);

open (my $fh, '>', $file);
my $int_count = 0;
my ($n_of_str, $len_of_str) = (0, 0);

$SIG{ALRM} = sub {$int_count == 0};

$SIG{INT} = sub {
    state $time = time;
    print STDERR "Double Ctrl+C for exit" if $int_count == 0;
    $int_count++;
    alarm (10);
    if ( (time - $time) < 10 and $int_count == 2) {
        my $size = -s $file;
        printf "%d %d %d\n", $size, $n_of_str, $len_of_str/$n_of_str;
        close($fh);
        exit;
    }
};

while (<STDIN>) {
    print $fh $_;
    $n_of_str++;
    chomp;
    $len_of_str += length $_;
}

my $size = -s $file;
printf "%d %d %d\n", $size, $n_of_str, $len_of_str/$n_of_str;