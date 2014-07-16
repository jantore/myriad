package Myriad::Schema;

use strict;

use base qw{ DBIx::Class::Schema };

__PACKAGE__->load_classes(qw{ Tracker Torrent Peer });


sub populate_test {
    my ($schema) = @_;

    my $tracker = $schema->resultset('Tracker')->create({
        host => 'tracker.example.net',
        title => 'Test Tracker',
        active => 1
    });

    my $torrent = $tracker->torrents->create({
        info_hash => '00000000000000000000',
        size      => 1000,
        title     => 'Test Torrent',
        active    => 1,
    });
}

1;
