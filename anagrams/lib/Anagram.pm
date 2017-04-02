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
    foreach my $w (@{$words_list}) {
        my $word = decode('utf8', $w);
        $word = lc $word;
        $word = encode('utf8', $word);
        
        my $key = join '', (sort {$a cmp $b} split '', $word);
        $first{$key} = $word unless exists $first{$key};
        
        if ( exists $result{$first{$key}} ) {
            
            unless (exists $all{$word}) {
                push @{$result{$first{$key}}}, $word;
                @{$result{$first{$key}}} = sort {$a cmp $b} @{$result{$first{$key}}};
            }
            $all{$word} = '';
            
        } elsif (exists $all{$first{$key}}) {
            
            $result{$first{$key}} = $all{$first{$key}};
            if (not exists $all{$word}) {
                push @{$result{$first{$key}}}, $word;
                $all{$word} = '';
            }
            
        }
        else {
            $all{$first{$key}} = [$word];
        }
    }
    
    return \%result;
}

1;