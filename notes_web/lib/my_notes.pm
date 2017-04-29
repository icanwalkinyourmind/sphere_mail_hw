package my_notes;
use utf8;
use Dancer2;
use Dancer2::Plugin::Database;
use Dancer2::Plugin::Auth::Extensible;
use HTML::Entities;
use Digest::CRC qw/crc64/;

our $VERSION = '0.1';

sub id_by_name {
    database->quick_lookup('users', { username => $_[0] }, 'id' );
}

any '/logout' => sub {
        session->destroy;
};

get '/' => require_login sub {
    template 'index';
};

get '/test' => sub {
    template 'inedx';
};

get '/login' => sub {
    template 'login' 
};

get qr{^/([a-f0-9]{16})$} => require_login sub {
    my ($id) = splat;
    $id = unpack 'Q', pack 'H*', $id;
    my $user_id = id_by_name(logged_in_user->{username});
    my $sth = database->prepare('SELECT * FROM owners where note_id = cast(? as signed) and user_id = ?');
    $sth->execute($id, $user_id);
    my $chek_rigthts = $sth->fetchrow_arrayref();
    $sth = database->prepare('SELECT note, title FROM notes where id = cast(? as signed)');
    unless ($sth->execute($id)) {
        response->status(404);
        return template 'index' => {err => ['Note not found']};
    }
    return template 'index'=> {err => ['It\'s not for your eyes']} unless $chek_rigthts;
    my $db_res = $sth->fetchrow_hashref();
    $db_res->{title} = encode_entities($db_res->{title}, '<>&"');
    $db_res->{title} = encode_entities($db_res->{title}, '<>&"');
    template 'show_note.tt' => {text => $db_res->{note}, title => $db_res->{title}};
};

post '/' => require_login sub {
    my $text = params->{text};
    my $title = params->{title}||'';
    my $users = params->{users};
    my @users = split /\s+/, $users;
    
    my @err = ();
    if (!$text) {
        push @err, 'Note text should exist';
    }
    
    if (length($text) > 255) {
        push @err, 'Too large note, you have only 255 symbols';
    }
    
    if ($title =~ /\W/) {
        push @err, 'Title may contain only [A-Za-z0-9]';
    }
    
    if (@err) {
        $text = encode_entities($text, '<>&"');
        $title = encode_entities($title, '<>&"');
        return template 'index' => {text => $text, title => $title, err => \@err};
    }
    
    my $create_time = time();
    my $sth = database->prepare('INSERT INTO notes (id, title, note, create_time) VALUES (cast(? as signed), ?, ?, from_unixtime(?)) ');
    
    my $id = '';
    my $check_db = '';
    my $try_count = 10;
    while (!$id or !$check_db) {
        unless (--$try_count) {
           $id = undef;
           last;
       }
       $id = crc64($text.$create_time.$id);
       $check_db = $sth->execute($id, $title, $text, $create_time);
    }
    unless ($id) {
        return template 'index' => {err => ["Try later"]};
    }
    
    my $username = logged_in_user->{username};
    my $user_id = id_by_name($username);
    $sth = database->prepare('INSERT INTO owners (note_id, user_id) VALUES (cast(? as signed), ?)');
    $sth->execute($id, $user_id);
    
    for (@users) {
        next if $_ eq $username;
        $user_id = id_by_name($_);
        $sth = database->prepare('INSERT INTO owners (note_id, user_id) VALUES (cast(? as signed), ?)');
        $sth->execute($id, $user_id);
    }
    
    redirect '/' . unpack 'H*', pack 'Q', $id;  
};

post '/login' =>  require_login sub {
    my ($success, $realm) = authenticate_user(
        params->{username}, params->{password}
    );
    if ($success) {
        app->change_session_id
            if app->can('change_session_id');
        session logged_in_user => params->{username};
        redirect '/';
    } else {
        return template 'login' => {err => ['Wrong username or password']};
    }
};

hook before_template_render => sub {
    if (logged_in_user) {
        my $tokens = shift;
        my $user_id = id_by_name(logged_in_user->{username});
        my $sth = database->prepare('SELECT cast(id as unsigned) as id, create_time, title from notes where id in (select note_id from owners where user_id = ?)');
        my $not_empty = $sth->execute($user_id);
        my $all_notes = $sth->fetchall_arrayref({});
        for (@$all_notes) {
            $_->{title} = encode_entities($_->{title}, '<>&"');
            $_->{id} = unpack 'H*', pack 'Q', $_->{id};
        }
        $tokens->{all_notes} = $all_notes if $not_empty;
    }
};

true;
