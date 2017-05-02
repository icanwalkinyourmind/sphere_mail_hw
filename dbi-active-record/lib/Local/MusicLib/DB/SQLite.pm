package Local::MusicLib::DB::SQLite;
use Mouse;
extends 'DBI::ActiveRecord::DB::SQLite';

sub _build_connection_params {
    my ($self) = @_;
    return [
        'dbi:SQLite:dbname=/home/vladislav/projects/sphere_mail_hw/dbi-active-record/tmp/muslib.db', '', '',
    ];
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;