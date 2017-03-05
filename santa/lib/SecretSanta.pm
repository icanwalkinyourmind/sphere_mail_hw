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
		}
		else {
			$members{$_}{spouse} = 'no spouse';
		}
	}
	
	my $gifter = [keys %members]->[-1];
	foreach my $key (keys %members) {
		if (not $key eq $gifter and defined $members{$key}){
			if ( not $gifter eq $members{$key}{spouse} and  not $key eq $members{$gifter}{spouse} ) {
				push @res, [$gifter, $key];
				if ($members{$key}{spouse} eq 'no spouse'){
					$members{$gifter}{spouse} = $key;
				}
				$gifter = $key;
			}
		}
	}

	return @res;
}

1;
