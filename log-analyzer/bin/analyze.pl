#!/usr/bin/perl

use strict;
use warnings;

my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;
    my %result;
    
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    
    my $i=1;
    
    while (my $log_line = <$fd>) {
        $log_line =~ s/(\"\w.+?\" )//g;
        $log_line =~ /(?<ip> \d+(\.\d+){3} ).*\[
                      (?<time> .+\d\d:\d\d ):.+\s+
                      (?<status> \d+ )\s+
                      (?<data> \d+ )
                      (.+(?<ratio> \d+.\d+ ) | .+)/x;
        my %request = %+;
        delete $request{ip};
        $result{$+{ip}} = [] if not defined $result{$+{ip}};
        push @{ $result{ $+{ip} } }, \%request;
    }
    
    close $fd;

    return \%result;
}

sub report {
    my $result = shift;
    my $i = 0;
    my (%top, %total);
    
    foreach my $ip ( sort { @{$result->{$b}} <=> @{$result->{$a}} } keys %{$result} ) {
        my %uniq;
        
        for ( @{$result->{$ip}} ) {
            
            my $ratio = (defined $_->{ratio}) ? $_->{ratio} : 1;
            $total{time}{$_->{time}} = '';
            $total{data} += $_->{data} * $ratio / 1024 if ($_->{status} == 200);
            $total{status}{$_->{status}} += $_->{data} / 1024;
            
            if ($i < 10) {
                $uniq{$_->{time}} = '';
                $top{$ip}{data} += $_->{data} * $ratio / 1024 if ($_->{status} == 200);
                $top{$ip}{status}{$_->{status}} += $_->{data} / 1024;
                
            }
        }
        
        $total{count} += @{$result->{$ip}};
        
        if ($i < 10) {
            $top{$ip}{count} = @{$result->{$ip}};
            $top{$ip}{avg} = $top{$ip}{count} / keys %uniq;
        }
        
        $i++;
    }
    
    $total{avg} = $total{count} / keys $total{time};
    delete $total{time};
    
    my @statuses = map {"data_$_"} sort { $a <=> $b  } keys $total{status};
    my $format = "\t%s" x (3+@statuses);
    printf "%s$format\n", 'IP', 'count', 'avg', 'data', @statuses;
    
    @statuses = map { int $total{status}{$_} } sort { $a <=> $b } keys $total{status};
    $format = "\t%d" x (1+@statuses);
    printf "%s\t%d\t%.2f$format\n", 'total', $total{count}, $total{avg}, $total{data}, @statuses;
    
    foreach my $ip (sort { $top{$b}{count} <=> $top{$a}{count} } keys %top) {
        
        for (keys $total{status}) {
            $top{$ip}{status}{$_} = 0 if (not defined $top{$ip}{status}{$_});
        }
        
        my @statuses = map { int $top{$ip}{status}{$_} } sort { $a <=> $b } keys %{$top{$ip}{status}};
        my $format = "\t%d" x (1+@statuses);
        
        printf "%s\t%d\t%.2f$format\n", $ip, $top{$ip}{count}, $top{$ip}{avg}, int $top{$ip}{data}, @statuses;
    }
    
}

 