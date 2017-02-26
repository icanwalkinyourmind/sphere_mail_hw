#!/usr/bin/perl -w
use strict;
use warnings;
sub run{
    my ($x, $y) = @_;
FOR:
    for (my $i = $x; $i <= $y; $i++){
        
        if ($i>1) {
            for (2..sqrt($i)){
                next FOR unless $i % $_;
            }
            print "$i\n" ;
        }
    }
}

1;
