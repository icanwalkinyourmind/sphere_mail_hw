package Local::Source::Text;

sub new {
    my ($class, %params) = @_;
    $params{delimetr} = "\n" unless defined $params{delimetr};
    return bless \%params, $class;
}

sub next {
    my $self = shift;
    my $delimetr =  $self->{delimetr};
    $self->{text} =~ s/(.*?(:?\Q$delimetr\E)|.+)//s;
    my $string = $1;
    local $/ = $delimetr;
    chomp $string;
    return $string;
}

sub has_next {
    my $self = shift;
    return length $self->{text} > 0;
}


1;