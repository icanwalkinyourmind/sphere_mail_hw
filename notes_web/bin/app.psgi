#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use my_notes;

my_notes->to_app;

use Plack::Builder;

builder {
    enable 'Deflater';
    my_notes->to_app;
}



=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use my_notes;
use Plack::Builder;

builder {
    enable 'Deflater';
    my_notes->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use my_notes;
use my_notes_admin;

builder {
    mount '/'      => my_notes->to_app;
    mount '/admin'      => my_notes_admin->to_app;
}

=end comment

=cut

