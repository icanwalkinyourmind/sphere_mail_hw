package Local::Row::JSON;

use strict;
use warnings;

sub new {
    my ($class, %param) = @_;
    bless \%param, $class;
}

sub get {
    my $self = shift;
    my ($name, $default) = @_;
    if ($self->{str} =~ /\"$name\": (.+?)(,|})/) {
        return $1
    } else {
        return $default;
    }
    
}


1;