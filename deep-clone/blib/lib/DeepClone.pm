package DeepClone;

use 5.010;
use strict;
use warnings;


my %refs; 

sub save_scalar{
	return my $new_scalra = shift;
}

sub clone {
	my $orig = shift;
	my $cloned;
	
	if (ref $orig eq 'ARRAY') {
		return save_scalar($orig) if defined $refs{$orig};
		$refs{$orig} = '';
		my @new_array = map clone($_), @{$orig};
		return \@new_array;
	}
	elsif (ref $orig eq 'HASH') {
		return save_scalar($orig) if defined $refs{$orig};
		$refs{$orig} = '';
		my %new_hash;
		for my $k (keys %{$orig}) {
			$new_hash{$k} = clone($orig->{$k});
		}
		return \%new_hash;
	}
	elsif (not ref $orig) {
		return save_scalar($orig);
	}
	else{
		return undef;
	}
		
	return $cloned;
}

1;