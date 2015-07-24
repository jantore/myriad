package Myriad::Test::Peer;

use Test::More;
use Test::Exception;

use strict;
use warnings;

sub run {
    my ($testclass, $schema) = @_;
    my $class = 'Myriad::Schema::ResultSet::Peer';

    my $rs = $schema->resultset('Peer');
    isa_ok $rs => $class;
    is $rs->count => 0 => 'still no torrents';

    can_ok $class => qw{
        active complete incomplete randomize swarm_speed ascending descending
    };

    my $now = $schema->now;

    my $t1 = $schema->resultset('Torrent')->find({
        info_hash => "\x00" x 20,
        tracker   => 'tracker.example.net',
    });
    $t1->peers->populate([
        [
            qw{ peer_id created modified address port
                downloaded uploaded remaining state secret }
        ],
        [
            'LEECHER1------------',
            $now->epoch,
            $now->epoch,
            '192.0.2.1', 12345, 0, 0, 1000, 1, "\x00" x 64
        ],
        [
            'LEECHER2------------',
            $now->clone->subtract(seconds => 86400)->epoch,
            $now->clone->subtract(seconds => 3600)->epoch,
            '192.0.2.2', 12345, 0, 0, 1000, 1, "\x01" x 64
        ],
        [
            'SEEDER1-------------',
            $now->epoch,
            $now->epoch,
            '192.0.2.3', 12345, 1000, 100, 0, 1, "\x02" x 64
        ],
        [
            'SEEDER2-------------',
            $now->clone->subtract(seconds => 86400)->epoch,
            $now->clone->subtract(seconds => 3600)->epoch,
            '192.0.2.4', 12345, 1000, 100, 0, 1, "\x02" x 64
        ],
    ]);

    is $t1->peers->count => 4 => 'four peers in total';
    is $t1->peers->active->count => 2 => 'only two active peers';

    $t1->announce(
        peer_id    => 'LEECHER2------------',
        ip         => '192.168.2.2',
        port       => 12345,
        downloaded => 1,
        uploaded   => 0,
        left       => 999,
        key        => "\x01" x 64
    );

    is $t1->peers->active->count => 3 => 'three active after announce';

    is $t1->peers->randomize->count => 4 => 'can randomize';
#    can_ok $peer => qw{
#        peer_id port address downloaded uploaded remaining state secret
#    };

}

1;
