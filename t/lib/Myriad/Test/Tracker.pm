package Myriad::Test::Tracker;

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Myriad::Test::Torrent;

sub run {
    my ($testclass, $schema) = @_;
    my $class = 'Myriad::Schema::ResultSet::Tracker';

    my $rs = $schema->resultset('Tracker');
    isa_ok $rs => 'Myriad::Schema::ResultSet::Tracker';
    is $rs->count => 0 => 'still no trackers';

    can_ok $class => qw{ active };

    $rs->populate([
        ['host',                'title'    ],
        ['tracker.example.net', 'Tracker 1'],
        ['tracker.example.org', 'Tracker2' ],
    ]);

    is $rs->count => 2 => 'two trackers now';
    my $t1 = $rs->find('tracker.example.net');
    isa_ok $t1 => 'Myriad::Schema::Tracker';

    can_ok $t1 => qw{ torrents };

    is $t1->host => 'tracker.example.net' => 't1 host correct';
    is $t1->title => 'Tracker 1' => 't1 title correct';
    is $t1->active => 1 => 't1 defaults to active';

    my $t2 = $rs->active->find('tracker.example.org');
    isa_ok $t2 => 'Myriad::Schema::Tracker';

    is $t2->host => 'tracker.example.org' => 't2 host correct';
    is $t2->title => 'Tracker2' => 't2 title correct';
    is $t2->active => 1 => 't2 defaults to active';

    $t2->update({ active => 0 });
    is $t2->active => 0 => 't2 no longer active';

    is $rs->active->count => 1 => 'one active tracker';

    $rs->create({
        host => 'tracker.example.com',
        title => 'Tracker 3',
        active => 0,
    });

    is $rs->active->count => 1 => 'still one active tracker';

    dies_ok {
        $rs->create({
            host => 'tracker.example.net',
            title => 'Tracker 4',
        });
    } 'creating two trackers with same host should fail';

    Myriad::Test::Torrent->run($schema, $t1);
}

1;
