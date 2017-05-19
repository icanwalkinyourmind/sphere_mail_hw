#!/usr/bin/perl -w
use strict;
use warnings;
use v5.010;
use POSIX qw(strftime);

my $text = strftime "%T", gmtime(200);
$text =~ /^(\d\d):(\d\d):(\d\d)$/;
my $time = $1*3600 + $2*60 + $3;
say $text;
say $time;