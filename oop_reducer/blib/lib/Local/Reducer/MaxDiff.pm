package Local::Reducer::MaxDiff;

use strict;
use warnings;
use Scalar::Util 'looks_like_number';

use base "Local::Reducer";

sub reduce {
    my $self = shift;
    my $row = "$self->{row_class}"->new(str => $self->{source}->next);
    my ($top, $bottom) = ($row->get($self->{top}), $row->get($self->{bottom}));
    if (looks_like_number($top) and looks_like_number($bottom)) {
        my $diff = abs($top - $bottom);
        $self->{initial_value} = $diff if $diff > $self->{initial_value};
    }
}

1;