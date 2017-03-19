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
        $word =~ s/(.+)/\F$1/;
        for (keys %result){
            if (/^[$word]+$/i and not defined $matched{$word}){
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
	    delete $result{$_};
	}
	else{
	   @{$result{$_}} = sort {$a cmp $b} @{$result{$_}};
	}
    }
    
    return \%result;
}

use constant EXAMPLE1   => [ qw(пятка слиток пятак ЛиСток стул ПяТаК тяпка столик слиток) ];

my $result = anagram(EXAMPLE1);

p %{$result};

1;