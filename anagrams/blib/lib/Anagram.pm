package Anagram;

use 5.010;
use strict;
use warnings;
use DDP;
use Data::Dumper;
use utf8;

sub anagram {
    my $words_list = shift;
    my %result;
    my %matched;
    foreach my $word (@{$words_list}) {
        utf8::decode($word);
        $word =~ s/(.+)/\L$1/;
        for (keys %result){
            if (/^[$word]+$/i and not defined $matched{$word}){
                utf8::encode($word);
                push @{$result{$_}}, $word;
                $matched{$word} = 'yes';
            }
        }
        unless (defined $matched{$word}){
            $result{$word} = [$word];
            $matched{$word} = 'yes';
        }
    }
    
    for (keys %result){
       	if (not defined $result{$_}->[1]){
	    delete $result{$_} ;
	}
	else{
	   @{$result{$_}} = sort {$a cmp $b} @{$result{$_}};
	}
    }
    
    return \%result;
}

1;