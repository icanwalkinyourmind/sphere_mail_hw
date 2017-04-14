package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use Web::Query;
use URI;
use DDP;

my $cv = AnyEvent->condvar;
$AnyEvent::HTTP::MAX_PER_HOST = 100;

sub run {
    my ($start_page, $parallel_factor) = @_;
    $start_page or die "You must setup url parameter";
    $parallel_factor or die "You must setup parallel factor > 0";

    my $total_size = 0;
    my @top10_list;
    my $count = 0;
    my $n_of_links = 0;
    my @requests;
    my %pages;
    push @requests, ['GET', $start_page];
    
    
    my $make_request; $make_request = sub {
        return if $count >= $parallel_factor;
        
        my $request = shift @requests;
        my $req_type = $request->[0];
        my $page = $request->[1];
        return if not $page or not $req_type;
        
        $count++;
        
        $cv->begin;
        http_request ($req_type => $page, timeout => 1,
            sub {
                if ($req_type eq 'GET') {
                    my ($body, $head) = @_;
                    if (not defined $page or not defined $body) {
                        $cv->end;
                        return;
                    }
                    my $base = URI->new($page);
                    utf8::decode($body);
                    $pages{$page} = $head->{'content-length'};
                    $total_size += $pages{$page};
                    if (keys %pages < 1000) {
                        wq($body)->find('a')->attr('href' =>
                            sub {
                                my $ref = URI->new_abs($_, $base)->as_string;
                                $ref =~ s/#.*//;
                                if (not exists $pages{$ref}
                                    and $ref =~ /^$start_page/) {
                                        $pages{$ref} = 0;
                                        $cv->send if  keys %pages >= 1000;
                                        $ref =~ s/\/$//;
                                        push @requests, ['HEAD', $ref];
                                }
                            }
                        );
                    }
                }
                elsif ($req_type eq 'HEAD'){
                    if (not exists $_[1]->{'content-type'}) {
                        $cv->end;
                        return;
                    }
                    if ($_[1]->{'content-type'} =~ m {.*text/html.*}
                        and keys %pages < 1000) {
                            unshift @requests, ['GET', $page];
                    }
                }
                else {
                    warn "wrong request type";
                    $cv->send;
                }
                $count--;
                if ($count < $parallel_factor) {
                    for (1..$parallel_factor-$count) {
                        $make_request->();
                    }
                }
                $cv->end;
            }
        ); 
    };
    
    $make_request->();
    $cv->recv;
    
    foreach (sort { $pages{$b} <=> $pages{$a} } keys %pages) {
        push @top10_list, $_;
        last if @top10_list == 10;
    }
    say scalar keys %pages;
    return $total_size, @top10_list;
}

1;
