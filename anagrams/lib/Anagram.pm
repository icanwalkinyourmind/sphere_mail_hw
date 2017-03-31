package Anagram;

use 5.010;
use strict;
use warnings;
use DDP;
use Data::Dumper;
use Encode;

sub anagram {
    my $words_list = shift;
    my %all;
    my %first;
    my %result;
    foreach my $word (@{$words_list}) {
    
        my $key =join '', (sort {$a cmp $b} split '', $word);
        $first{$key} = $word unless exists $first{$key};
        
        if ( exists $result{$first{$key}} ) {
            unless (exists $all{$word}) {
                push @{$result{$first{$key}}}, $word;
            }
            $all{$word} = '';
        } elsif (exists $all{$first{$key}}) {
            $result{$first{$key}} = $all{$first{$key}};
            push @{$result{$first{$key}}}, $word;
            $all{$word} = '';
        } else {
            $all{$first{$key}} = [$word];
        }
    }
    
    return \%result;
}

1;