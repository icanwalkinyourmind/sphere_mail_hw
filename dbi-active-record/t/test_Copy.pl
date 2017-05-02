use FindBin; use lib "$FindBin::Bin/../lib";
use Local::MusicLib::Track;
use DateTime;
use DDP;

my $dt = DateTime->now;
my $self = Local::MuscicLib::Track->new;
p $self;