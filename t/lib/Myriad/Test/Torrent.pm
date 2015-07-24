package Myriad::Test::Torrent;

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Myriad::Test::Peer;

sub run {
    my ($testclass, $schema, $tracker) = @_;
    my $class = 'Myriad::Schema::ResultSet::Torrent';

    my $rs = $schema->resultset('Torrent');
    isa_ok $rs => $class;
    is $rs->count => 0 => 'still no torrents';

    can_ok $class => qw{
        active num_completes transferred_bytes
    };

    my $t1 = $schema->resultset('Tracker')->find('tracker.example.net');
    my @t1t = $t1->torrents->populate([
        ['info_hash', 'size', 'title'    ],
        ["\x00" x 20, 1000,   'Torrent 1'],
        ["\x11" x 20, 2000,   'Torrent 2'],
    ]);

    my $t2 = $schema->resultset('Tracker')->find('tracker.example.org');
    my @t2t = $t2->torrents->populate([
        ['info_hash', 'size', 'title'    ],
        ["\x22" x 20, 3000,   'Torrent 1'],
        ["\x33" x 20, 4000,   'Torrent 2'],
    ]);

    $t2->torrents->find({ info_hash => "\x33" x 20 })
        ->update({ active => 0 });

    is $rs->count => 4 => 'four torrents in this tracker';
    is $rs->active => 3 => 'only three active torrents';
    is $t1->torrents->count => 2 => 'two torrents on tracker';

    dies_ok {
        $t1->torrents->create({
            info_hash => "\x00" x 20,
            size      => 1001,
            title     => 'Torrent 3',
        })
    } 'multiple torrents with same info hash not allowed';

    my $torrent = $t1->torrents->find({ info_hash => "\x00" x 20 });
    isa_ok $torrent => 'Myriad::Schema::Torrent';

    can_ok $torrent => qw{ announce scrape };

    Myriad::Test::Peer->run($schema);
}

1;
