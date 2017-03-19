package myconst;

use strict;
use 5.010;
use warnings;
use Scalar::Util 'looks_like_number';
use List::Util qw /any/;
our $VERSION = v1.00;

sub import {
    shift;
    my @input = @_;
    no strict 'refs';
    our $caller = caller;
    push @{$caller."::ISA"}, 'Exporter';
    ${$caller."::EXPORT_TAGS"}{all}  = [];
    for (my $i=0; $i <= $#input; $i+=2) {
        
        if (ref $input[$i] or not defined $input[$i]) { die }
        
        #создаём константы
        elsif (not ref $input[$i+1] and @input >= 2) {
            my ($k, $v) = ($input[$i], $input[$i+1]);
            die unless ($k =~ /^\w+$/ or $v =~ /^\w+$/);
            *{$caller . "::$k"} = sub () { $v };
            push @{ ${$caller."::EXPORT_TAGS"}{all} }, $k;
            push @{ $caller."::EXPORT_OK" }, $k;
        }
        
        #создаём группы констант
        elsif (ref $input[$i+1] and @input >= 2) {
            die unless ($input[$i] =~ /^\w+$/ or ref $input[$i+1] eq 'HASH');
            my %new = %{ $input[$i+1] };
            ${$caller."::EXPORT_TAGS"}{$input[$i]}  = [];
            while (my ($k, $v) = each %new) {
                die unless ($k =~ /^\w+$/ or $v =~ /^\w+$/);
                die if (ref $v or looks_like_number($k));
                *{$caller . "::$k"} =  sub () { $v };
                push @{ ${$caller."::EXPORT_TAGS"}{$input[$i]} }, $k;
                push @{ ${$caller."::EXPORT_TAGS"}{all} }, $k;
                push @{ $caller."::EXPORT_OK" }, $k;
            }
        }
    }

}


1;



