package myconst;

use strict;
use warnings;
use Scalar::Util 'looks_like_number';
our $VERSION = v1.00;

sub import {
    shift;
    my @input = @_;
    no strict 'refs';
    our $caller = caller;
    push @{$caller."::ISA"}, 'Exporter';
    ${$caller."::EXPORT_TAGS"}{all}  = [];
    for (my $i=0; $i <= $#input; $i+=2) {
        
        #�������� ��������
        if (not ref $input[$i+1]) {
            my ($k, $v) = ($input[$i], $input[$i+1]);
            *{$caller . "::$k"} = sub () { $v };
            push @{ ${$caller."::EXPORT_TAGS"}{all} }, $k;
            push @{ $caller."::EXPORT_OK" }, $k;
        }
        
        #�������� ����� ��������
        if (ref $input[$i+1] eq 'HASH') {
            my %new = %{ $input[$i+1] };
            ${$caller."::EXPORT_TAGS"}{$input[$i]}  = [];
            while (my ($k, $v) = each %new) {
                *{$caller . "::$k"} =  sub () { $v };
                push @{ ${$caller."::EXPORT_TAGS"}{$input[$i]} }, $k;
                push @{ ${$caller."::EXPORT_TAGS"}{all} }, $k;
                push @{ $caller."::EXPORT_OK" }, $k;
            }
        }
    }

}


1;



