package VFS;
use utf8;
use strict;
use warnings;
use 5.010;
use DDP;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
no warnings 'experimental::smartmatch';
use FindBin;
use lib "$FindBin::Bin/../lib";

sub b_to_json {
	return $_[0] ? JSON::XS::true : JSON::XS::false;
}

sub mode2s {
	my $mode = shift;
	
	my $result = {};
	
	my @var = qw /1 2 4 8 16 32 64 128 256/;
	
	for my $group (qw /other group user/) {
		for my $right (qw /execute write read/) {
			$result->{$group}->{$right} = b_to_json($mode & shift @var);
		}
	}
	
	return $result;
}

sub del {
	return substr($_[0], 0, $_[1], '');
}

sub parse {
	my $buf = shift;
	my %result;
	my %links;
	my $link = \%result;
	$links{$link} = $link;
	
	my $first = unpack "a", $buf;
	
	die "The blob should start from 'D' or 'Z'" unless ( $first =~ /[DZ]/);
	
W:	while ($buf) {
		my $command = unpack "a", $buf;
		del($buf, 1);		
		for ($command) {
			when ('D') {
				my $name = unpack "n/a", $buf;
				del($buf, length($name)+2);
				utf8::decode($name);
				
				my $mode = unpack "n", $buf;
				del($buf, 2);
				
				if (exists $link->{list}) {
					my $new_dir = {};
					$links{$new_dir} = $link;
					push @{$link->{list}}, $new_dir;
					$link = $new_dir;
					$new_dir->{name} = $name;
					$new_dir->{mode} = mode2s($mode);
					$new_dir->{type} = 'directory';
				} else {
					$link->{name} = $name;
					$link->{mode} = mode2s($mode);
					$link->{type} = 'directory';
				}
			}
			when ('F') {
				my $name = unpack "n/a", $buf;
				del($buf, length($name)+2);
				utf8::decode($name);
				
				my $mode = unpack "n", $buf;
				del($buf, 2);
				
				my $size =  unpack "N", $buf;
				del($buf, 4);
				
				my $sha1 = unpack "H40", $buf;
				del($buf, 20);
				
				my $new_file = {};
				push @{$link->{list}}, $new_file;
				
				$new_file->{name} = $name;
				$new_file->{mode} = mode2s($mode);
				$new_file->{size} = $size;
				$new_file->{hash} = $sha1;
				$new_file->{type} = 'file';
			}
			when ('I') {
				$link->{list} = [];
			}
			when ('U') {
				$link = $links{$link};
			}
			when ('Z') {
				last W; 
			}
			
		}
	}
	
	die "Garbage ae the end of the buffer" if $buf;
	
	return \%result;
}

1;
