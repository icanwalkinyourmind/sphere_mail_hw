package Local::Reducer::Sum;

use strict;
use warnings;
use base "Local::Reducer";

sub reduce {
    my $self = shift;
    my $row = "$self->{row_class}"->new(str => $self->{source}->next);
    if (defined $row->get($self->{field})){
        $self->{initial_value} += $row->get($self->{field});
    }
}

1;