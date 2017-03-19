use v5.010;
use strict;
use warnings;

use Local::Reducer::MaxDiff;
use Local::Source::Array;
use Local::Source::Text;
use Local::Row::Simple;

my $reducer = Local::Reducer::MaxDiff->new(
    top => 'received',
    bottom => 'sended',
    source => Local::Source::Text->new(text =>"sended:1024,received:2048\nsended:2048,received:10240"),
    row_class => 'Local::Row::Simple',
    initial_value => 0,
);

say $reducer->reduce_all();