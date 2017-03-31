#!/usr/bin/perl -w
use strict;
use warnings;
use v5.010;
use AnyEvent::HTTP;

   my $request = http_request GET => "http://mail.ru/", sub {
      my ($body, $hdr) = @_;
      print "$body\n";
   };
