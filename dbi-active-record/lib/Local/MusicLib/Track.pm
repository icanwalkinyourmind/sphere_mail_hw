package Local::MusicLib::Track;

use DBI::ActiveRecord;
use Local::MusicLib::DB::SQLite;

use POSIX qw(strftime);
use DateTime::Format::MySQL;

db "Local::MusicLib::DB::SQLite";

table 'tracks';

has_field id => (
    isa => 'Int',
    auto_increment => 1,
    index => 'primary',
);

has_field name => (
    isa => 'Str',
    index => 'common',
    default_limit => 100,
);

has_field extension => (
    isa => 'Str',
);

has_field create_time => (
    isa => 'DateTime',
    serializer => sub { DateTime::Format::MySQL->format_datetime($_[0]) },
    deserializer => sub { DateTime::Format::MySQL->parse_timestamp($_[0])  },
);

has_field album_id => (
    isa => 'Int',
    index => 'common',
    default_limit => 100,
);

has_field duration => (
    isa => 'Str',
    serializer => sub {$_[0] =~ /^(\d\d):(\d\d):(\d\d)$/; $1*3600 + $2*60 + $3},
    deserializer => sub { strftime "%T", gmtime($_[0]) },
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;