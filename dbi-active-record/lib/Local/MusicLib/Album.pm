package Local::MusicLib::Album;

use DBI::ActiveRecord;
use Local::MusicLib::DB::SQLite;

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

has_field type => (
    isa => 'Str',
);

has_field create_time => (
    isa => 'DateTime',
    serializer => sub { DateTime::Format::MySQL->format_datetime($_[0]) },
    deserializer => sub { DateTime::Format::MySQL->parse_timestamp($_[0])  },
);

has_field artist_id => (
    isa => 'Int',
    index => 'common',
    default_limit => 100,
);

has_field published_at => (
    isa => 'Int'
);

no DBI::ActiveRecord;
__PACKAGE__->meta->make_immutable();

1;