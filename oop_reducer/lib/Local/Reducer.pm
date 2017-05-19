package Local::Reducer;

use strict;
use warnings;

our $VERSION = '1.00';

sub new {
    my ($class, %params) = @_;
    return bless \%params, $class;
}

sub reduce_n {
    my ($self, $n) = @_;
    for (1..$n) {
        $self->reduce();
    }
    return $self->{initial_value};
}

sub reduce_all {
    my $self = shift;
    while ($self->{source}->has_next) {
        $self->reduce();
    }
    return $self->{initial_value};
}

sub reduced {
    my $self = shift;
    return $self->{initial_value};
}

1;
