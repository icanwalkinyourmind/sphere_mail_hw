package Local::MatrixMultiplier;

use strict;
use warnings;
use POSIX ":sys_wait_h";
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
    my %forks;
    my $n_of_child = 0;
    
    $SIG{CHLD} = sub {
        while ((my $child = waitpid(-1, WUNTRACED)) > 0) {
            my $r = $forks{$child};
            while (<$r>) {
                my @values = split " ", $_;
                $res->[$values[0]]->[$values[1]] = $values[-1];
            }
            close $r;
            delete $forks{$child};
            $n_of_child--;
        }
    };
    
    die 'both matrix should be square' if @{$mat_a} != @{$mat_b};
    
    
    for my $i (0..$N) {
        for my $j (0..$N) {
            if ($n_of_child < $max_child) {
                my ($r, $w);
                pipe($r,$w);
                my $pid = fork(); $n_of_child++;
                $forks{$pid} = $r;
                if ($pid) {
                    close $w;
                } elsif (not defined $pid) { 
                    say "can't fork";
                } else {
                    close $r;
                    print $w "$i $j ".mult_rc($mat_a->[$i], $mat_b->[$j]);
                    close $w;
                    exit;
                }
            } else {
                $res->[$i]->[$j] = mult_rc($mat_a->[$i], $mat_b->[$j]);
                sleep(1);
            }
        }
    }
    
    return $res;
}

1;
