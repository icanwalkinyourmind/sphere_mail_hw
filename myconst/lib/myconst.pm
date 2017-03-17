package myconst;

use strict;
use warnings;
use Scalar::Util 'looks_like_number';
our $VERSION = v1.00;

sub import {
    shift;
    my @input = @_;
    no strict 'refs';
    our %const;
    $const{all} = {};
    my $caller = caller;
    
    my $i = 0;
    while ($i <= $#input) {
        #создание констант
        if (not ref $input[$i+1]
                and not $input[$i] =~ /^:/
                and not defined $const{all}{$input[$i]}) {
            
            my ($k, $v) = ($input[$i], $input[$i+1]);
            $const{all}{$k} = sub { $v };
            *{$caller . "::$k"} = $const{all}{$k};
            $i+=2;
            next;
            
        }
        
        #создание групп констант
        if (ref $input[$i+1] eq 'HASH') {
            my %new = %{ $input[$i+1] };
            while (my ($k, $v) = each %new) {
                $const{all}{$k} = sub { $v };
                $const{$input[$i]}{$k} = $const{all}{$k};
                *{$caller . "::$k"} = $const{all}{$k};
            }
            $i+=2;
            next;
        }
        
        #вызов списка констант
        if ($input[$i] =~ s/^://) {
            while (my ($k, $v) = each %{ $const{$input[$i]} }) {
                $const{all}{$k} = sub { $v };
                $const{$input[$i]}{$k} = $const{all}{$k};
                *{$caller . "::$k"} = $const{all}{$k};
            }
            $i+=2;
            next;
        }
        
        
    }
}


1;



