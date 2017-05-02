package Local::Test_track;
use lib "/home/vladislav/projects/sphere_mail_hw/dbi-active-record/lib/";
use Test::Class::Moose;
use Local::MusicLib::Track;
use DateTime;


sub test_setup {
    my ($self) = @_;

    my $dt = DateTime->now;
    
    $self->{track} = Local::MuscicLib::Track->new(
        name => 'this is a track',
        album_id => 1,
        duration => '00:04:20',
        create_time =>  $dt,
        extansion => 'flac',
    );

    return;    
}


sub test_construction {
        my $dt = DateTime->now;
        my $test = shift;
        my $obj  = Local::MuscicLib::Track->new(
            name => 'this is a track',
            album_id => 1,
            duration => '00:04:20',
            create_time =>  $dt,
            extansion => 'flac',
         );
        isa_ok $obj, 'Local::MuscicLib::Track';
    
    return;
}

sub test_insert_select {
    my $self = shift;
    
    $self->{track}->insert();
    my $select = $self->{track}->select('name', 'this is a track', 1);
    
    cmp_deeply(
        $self->{track},
        $select,
    );
    
    return;
}

sub test_update {
    my $self = shift;
    
    my $new_track = Local::MuscicLib::Track->new(
        name => 'this is a new track',
        album_id => 1,
        duration => '00:04:20',
        create_time =>  $self->{track}->{create_time},
        extansion => 'mp3',
        id => $self->{track}->{id},
    );
    
    
    $self->{track}->{name} = 'this is a new track';
    $self->{track}->{extansion} = 'mp3';
    $self->{track}->update();
    
    my $updated = $self->{track}->select('id', $self->{track}->{id}, 1);
    
    cmp_deeply(
        $self->{track},
        $updated,
    );
    
    return;
}

sub test_delete {
    my $self = shift;
    
    $self->{track}->delete();
    
    ok ($self->{track}->select('id', $self->{track}->{id}, 1));
    
    return;
}

1;

