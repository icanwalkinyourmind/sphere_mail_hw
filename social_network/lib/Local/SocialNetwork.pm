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
         left join relations on users.id = relations.who
         where who = null;",
        { Slice => {} }
    );
    return $array_ref;
}

sub friends {
    my $self = shift;
    my ($first, $second) = @_;
    if ($first == $second) {
        die "choose not similar ID's";
    }
    my $sth = $self->{dbh}->prepare(
       "select * from users where id in
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
    my $count = 0;
    my %visited;
    
    if ($first == $second) {
        die "choose not similar ID's";
    }
    
    my $get_friends = sub {
        my $users = shift;
        my $sth = $self->{dbh}->prepare(
            "select withwho from relations
             where who in (?)"
        );
        $sth->execute($users);
        my $array_ref = $sth->fetchall_arrayref();
    };
    
    my @next = ($first);
    while (@next){
        $visited{$_} = 0 for (@next);
        my $next = join ', ', @next;
        @next = ();
        my $next_circle = $get_friends->($next);
        for (@$next_circle) {
            if ($second == $_) {
                return $count;
            }
            if (not exists $visited{$_}) {
                push @next, $_;
            }
        }
        $count++;
    }
    return $count;
}


1;
