package DeepClone;

use 5.010;
use strict;
use warnings;
use DDP;

my %refs; 

sub save_scalar{
	return my $new_scalar = shift;
}

sub clone {
	my $orig = shift;
	
	if (ref $orig eq 'ARRAY') {
		return $refs{$orig} if exists $refs{$orig};
		my @new_array;
		$refs{$orig} = \@new_array;
		@new_array = map clone($_), @{$orig};
		return undef if defined $refs{subref};
		return \@new_array;
	}
	elsif (ref $orig eq 'HASH') {
		return $refs{$orig} if exists $refs{$orig};
		my %new_hash;
		$refs{$orig} = \%new_hash;
		for my $k (sort {$a cmp $b} keys %{$orig}) {
			$new_hash{$k} = clone($orig->{$k});
		}
		return undef if defined $refs{subref};
		return \%new_hash;
	}
	elsif (not ref $orig) {
		return save_scalar($orig);
	}
	elsif (ref $orig eq 'CODE') {
		$refs{subref} = '';
		return undef;
	} else {
		return undef;
	}
	
}

1;
