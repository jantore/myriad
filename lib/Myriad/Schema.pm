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

    my $seeder = $torrent->peers->create({
        peer_id   => 'TESTSEEDER',
        port      => 12345,
        address   => '1.1.1.1',
        remaining => 0,
    });

    my $leecher = $torrent->peers->create({
        peer_id   => 'TESTLEECHER',
        port      => 54321,
        address   => '2.2.2.2',
        remaining => 1000,
    });
}

1;
