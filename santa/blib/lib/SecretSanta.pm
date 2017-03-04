package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;

sub calculate {
	my @members = @_;
	my @res;
	my %members;
	
	foreach (@members) {
		if (ref $_) {
			$members{$_->[0]}{spouse} = $_->[1];
			$members{$_->[1]}{spouse} = $_->[0];
			$members{$_->[0]}{have_gift} = '';
			$members{$_->[0]}{gifter} = '';
			$members{$_->[1]}{have_gift} = '';
			$members{$_->[1]}{gifter} = '';
		}
		else {
			$members{$_}{spouse} = 'no spouse';
			$members{$_}{gifter} = '';
			$members{$_}{have_gift} = '';
		}
	}
	
	my $gifter = [keys %members]->[-1];
	foreach my $key (keys %members) {
		if (not $key eq $gifter and defined $members{$key}){
			unless ($gifter eq $members{$key}{spouse}) {
				push @res, [$gifter, $key];
				if ($members{$key}{spouse} eq 'no spouse'){
					$members{$key}{spouse} = $gifter;
				}
				else{
					$members{$gifter}{spouse} = $key;
				}
				$members{$key}{have_gift} = 1;
				$members{$key}{gifter} = 1;
				$gifter = $key;
				delete $members{$key};
			}
		}
		#if ($members{$key}{have_gift} and $members{$key}{gifter}){
		#	delete $members{$key};
		#}
	}


	return @res;
}

1;
