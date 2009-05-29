package Myriad::Schema;
use base qw{ DBIx::Class::Schema };

__PACKAGE__->load_classes(qw{ Tracker Torrent Peer });

1;
