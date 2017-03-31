package Local::MatrixMultiplier;

use strict;
use warnings;
use DDP;
use POSIX ":sys_wait_h";
use IPC::Open2;
use v5.010;



sub transp {
    my $matrix = shift;
    my @cols;
    for my $i (0..@{$matrix}-1) {
        my @col;
        for my $j (0..$#{$matrix}) {
            push @col, $matrix->[$j]->[$i];
        }
        push @cols, \@col;
    }
    return \@cols;
}

sub mult_rc {
    my ($row, $col) = @_;
    my $res;
    $res += $row->[$_]*$col->[$_] for (0..@{$row}-1);
    return $res;
}

sub mult {
    my ($mat_a, $mat_b, $max_child) = @_;
    my $res = [];
    
    my $N = @{$mat_a}-1;
    $mat_b = transp($mat_b);
    
    die 'both matrix should be square' if @{$mat_a} != @{$mat_b};
    
    my $n_of_child = 0;
    
    for my $i (0..$N) {
        for my $j (0..$N) {
            my ($r, $w);
            pipe($r,$w);
            my $pid = fork();
            if ($pid) {
                close $w;
                while (<$r>) {
                    my @values = split " ", $_;
                    my $t = $values[-1];
                    $res->[$values[0]]->[$values[1]] = $values[-1];
                };
                close $r;
                waitpid($pid, 0);
            } elsif (not defined $pid) { 
                say "can't fork";
            } else {
                close $r;
                print $w "$i $j ", mult_rc($mat_a->[$i], $mat_b->[$j]);
                close $w;
                exit;
            }
        }
    }
    
    return $res;
}

1;
