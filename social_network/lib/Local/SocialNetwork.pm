package Local::SocialNetwork;

use strict;
use warnings;
use DBI;
use v5.10;
use utf8;
use DDP;

=encoding utf8

=head1 NAME

Local::SocialNetwork - social network user information queries interface

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut
sub new {
    my ($class, %params) = @_;
    return bless \%params, $class;
}

sub connect {
    my ($self, $config) = @_;
    my $fpath = $config->{path};
    $self->{dbh} = DBI->connect("dbi:SQLite:dbname=$fpath",
    "","", {RaiseError => 1});
}

sub disconnect {
    my $self = shift;
    $self->{dbh}->disconnect;
}

sub add_users {
    my ($self, $file) = @_;
    my $fd;
    open $fd, "<", $file or die "Can't open '$file': $!";
    my $sth = $self->{dbh}->prepare(
        'INSERT INTO users(id, first_name, last_name)
         VALUES (?, ?, ?)'
    );
    my $i = 0;
    $self->{dbh}->begin_work;
    while (<$fd>) {
        $self->{dbh}->begin_work if $i == 0;
        utf8::decode($_);
        /(\d+)\s(\w+)\s(\w+)/;
        $sth->execute($1, $2, $3);
        $self->{dbh}->commit if $i == 10000;
    }
    $self->{dbh}->commit;
}

sub add_relations {
    my ($self, $file) = @_;
    my $fd;
    open $fd, "<", $file or die "Can't open '$file': $!";
    my $sth = $self->{dbh}->prepare(
        'INSERT INTO relations(who, withwho)
         VALUES (?, ?)'
    );
    my $i = 0;
    $self->{dbh}->begin_work;
    while (<$fd>) {
        utf8::decode($_);        
        /(\d+)\s(\d+)/;
        $sth->execute($1, $2);
    }
    $self->{dbh}->commit;
}

sub nofriends {
    my $self = shift;
    my $array_ref = $self->{dbh}->selectall_arrayref(
        "select *
         from users
         where id not in (select distinct who from relations);",
        { Slice => {} }
    );
    return $array_ref;
}

sub friends {
    my $self = shift;
    my ($first, $second) = @_;
    my $sth = $self->{dbh}->prepare(
       "select *from users where id in
        (select withwho from relations 
        where who = ? and withwho in (select withwho from relations where who = ?))"  
    );
    $sth->execute($first, $second);
    my $array_ref = $sth->fetchall_arrayref({});
    return $array_ref;
}

sub handshakes {
    my $self = shift;
    my ($first, $second) = @_;
    if ($first == $second) {
        return "choose not similar ID's";
    }
    my $count = 0;
    my (%visited, %fired);
    my @queue;
    $visited{$first} = 0;
    my $get_friends = sub {
        my $user = shift;
        my $sth = $self->{dbh}->prepare(
            "select withwho from relations
             where who = ?"
        );
        $sth->execute($user);
        my $hash_ref = $sth->fetchall_hashref('withwho');
    };
    my $start = $get_friends->($first);
    push @queue, keys %{$start};
    while (@queue) {
        $count++;
        my @q = @queue;
        @queue = ();
        for (@q) {
            $visited{$_} = 0;
            my $friends = $get_friends->($_);
            if (exists $friends->{$second}) {
                @queue = ();
                last;
            } else {
                for (keys %{$friends}) {
                    if (not exists $visited{$_} and
                        not exists $fired{$_}) {
                        $fired{$_} = 0;
                        push @queue, $_;
                    }
                }
            }
        }
    }
    return $count;
}


1;
