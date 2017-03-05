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
			$members{$_->[0]}{gifter} = '';
			$members{$_->[1]}{gifter} = '';
		}
		else {
			$members{$_}{spouse} = '';
			$members{$_}{gifter} = '';
		}
	}
	
	my $gifter = [keys %members]->[-1];
	for (1..2){
		foreach my $key (keys %members) {
			if (not $key eq $gifter){
				if ( (not $gifter eq $members{$key}{spouse}) 
				and  (not $key eq $members{$gifter}{spouse})
				and (not $members{$gifter}{gifter})
				) {
					push @res, [$gifter, $key];
					$members{$gifter}{gifter} = 1;
					if ($members{$key}{spouse}){
						$members{$gifter}{spouse} = $key;
					}
					else{
						$members{$key}{spouse} = $gifter;
					}
					
					$gifter = $key;
				}
			}
		}
	}

	return @res;
}

1;