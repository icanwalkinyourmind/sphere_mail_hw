#!/usr/bin/perl -w
use strict;
use warnings;
use AnyEvent;
use DDP;
use AnyEvent::Socket;
use AnyEvent::HTTP;
use AnyEvent::Handle;
use IO::Handle;
use LWP::UserAgent;
use v5.10;
use HTTP::Request;
no warnings 'experimental';

my $cv = AnyEvent->condvar;

my %connections;
my %links;
$cv->begin;
tcp_server '0.0.0.0', 8888, sub {
    my $fh = shift;
    $cv->begin;
    my $hdl; $hdl = AnyEvent::Handle->new( fh => $fh,
          on_read => sub {
                my $line = delete $_[0]{rbuf};
                for ($line) {
                      when (/^GET$/) {
                          if (exists $links{$_[0]}) {
                             my $ua = LWP::UserAgent->new;
                             my $respones = $ua->get($links{$_[0]});
                             $_[0]->push_write($respones->content);
                          } else {
                             $_[0]->push_write('setup URL'); 
                          }
                      }
                      when (/^HEAD$/) {
                          if (exists $links{$_[0]}) {
                             my $ua = LWP::UserAgent->new;
                             my $respones = $ua->head($links{$_[0]});
                             $_[0]->push_write($respones->as_string);
                          } else {
                             $_[0]->push_write('setup URL'); 
                          }
                      }
                      when (/^FIN$/) {
                          delete $connections{$_[0]};
                          $cv->send;
                      }
                      when (/^URL\s+/) {
                          $_ =~ s/^URL\s+//;
                          if ($_ =~ /^(https?:\/\/)([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/) { 
                              $links{$_[0]} = $_;
                          } else {
                              $_[0]->push_write("not valid URL")
                          }
                      }
                      default {$_[0]->push_write("wrong command")}
                }
          },
          on_error => sub {say 'connection closed'},
    );
    $connections{$hdl} = $hdl;
   };


$cv->recv;