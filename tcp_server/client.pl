#!/usr/bin/perl -w
use strict;
use warnings;
use AnyEvent::Socket;
use AnyEvent::Handle;
use v5.10;

my $cv = AnyEvent->condvar;
my $connection;

$cv->begin;
tcp_connect '0.0.0.0', 8888, sub {
    my ($fh) = @_ or die "connect failed: $!";
    my $s = 'GET https://mail.ru';
    print "Подключились! Командуй шеф, могу выполнять вот эти команды:\n
    Первым делом URL http(s)://smth.org\n
    Дальше на выбор GET или HEAD\n
    Завершить сеанс, а заодно и вырубить сервер FIN\n";
    my $hdl; $hdl = AnyEvent::Handle->new( fh => $fh,
          on_read => sub {
                print delete $_[0]{rbuf};
          },
          on_error => sub {say 'connection closed'; $cv->end;}
    );
    $connection = $hdl;
};

my $in; $in = AnyEvent::Handle->new(fh => \*STDIN,
            on_error => sub {              
                undef $connection;
                $cv->end;
            },
            on_read => sub {
                $connection->push_write(delete $_[0]->{rbuf});
            },
        );

$cv->recv;

