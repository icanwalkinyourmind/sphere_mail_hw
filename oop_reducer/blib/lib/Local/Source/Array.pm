package Local::Source::Array;
    
use strict;
use warnings;

sub new {
    my ($class, %params) = @_;
    $params{iter} = 0;
    $params{len} = @{$params{array}};
    return bless \%params, $class;
}

sub next {
    my $self = shift;
    my $i = $self->{iter};
    $self->{iter} ++;
    return $self->{array}[$i];
}

sub has_next {
    my $self = shift;
    return $self->{iter} < $self->{len};
}


1;