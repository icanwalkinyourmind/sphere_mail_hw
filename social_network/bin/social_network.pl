#!/usr/bin/env perl
use strict;
use warnings;
use FindBin; use lib "$FindBin::Bin/../lib";
use Local::SocialNetwork;
use Getopt::Long;
use JSON::XS;
use v5.010;

my @users;
GetOptions ("user=i" => \&add_user);
sub add_user {
    push @users, $_[1];
}

my $config = {};
my $conf_file = "$FindBin::Bin/../etc/config";
my $fd;
open $fd, '<', $conf_file or die "can't open config";
while (<$fd>) {
    chomp;
    $config->{$1} = $2 if /(\w+):\s(.+)/;
}
close $fd;

my $db = Local::SocialNetwork->new();
$db->connect($config);

my $command = $ARGV[0] or die "no args";
if ($command eq 'friends') {
    die "wrong number of users" if @users != 2;
    my $json = JSON::XS->new->encode($db->friends($users[0], $users[1]));
    say $json;
}
elsif ($command eq 'num_handshakes') {
    die "wrong number of users" if @users != 2;
    say $db->handshakes($users[0], $users[1]); 
}
elsif ($command eq 'nofriends') {
    die "wrong number of users" if scalar @users != 0;
    my $json = JSON::XS->new->encode($db->friends($users[0], $users[1]));
    say $json;
} else {
    die "wrong command";
}
$db->disconnect;
