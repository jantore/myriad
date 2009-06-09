package Myriad::Schema::Torrent;

use strict;
use warnings;

use base qw{ DBIx::Class };

use Myriad::Schema::Peer;
use Myriad::Util qw{ berror };

__PACKAGE__->load_components(qw{
    +Myriad::Schema::Component::Torrent::ValidateAnnounce
    +Myriad::Schema::Component::Torrent::Announce
    +Myriad::Schema::Component::Torrent::GetPeers
    +Myriad::Schema::Component::Torrent::Scrape
    Core
});

__PACKAGE__->table('Torrent');

__PACKAGE__->add_columns(
    'info_hash' => {
        data_type => 'blob',
        size => '20',
        is_nullable => 0,
    },
    'tracker' => {
        data_type     => 'varchar',
        size          => '128',
        is_nullable   => 0,
    },
    'created' => {
        data_type     => 'integer',
        size          => 10,
        is_nullable   => 0,
    },
    'modified' => {
        data_type     => 'integer',
        size          => 10,
        is_nullable   => 1,
        default_value => undef,
    },
    'active' => {
        data_type     => 'integer',
        size          => 1,
        is_nullable   => 0,
        default_value => 1,
    },
    'size' => {
        data_type     => 'integer',
        is_nullable   => 0,
    },
    'title' => {
        data_type     => 'varchar',
        size          => '128',
        is_nullable   => 0,
    },
    'num_seeders' => {
        data_type     => 'integer',
        is_nullable   => 0,
        default_value => 0,
    },
    'num_leechers' => {
        data_type     => 'integer',
        is_nullable   => 0,
        default_value => 0,
    },
    'num_completes' => {
        data_type     => 'integer',
        is_nullable   => 0,
        default_value => 0,
    },
);

__PACKAGE__->set_primary_key( 'info_hash', 'tracker' );

__PACKAGE__->belongs_to(
    'tracker',
    'Myriad::Schema::Tracker',
    {
        'foreign.host' => 'self.tracker'
    }
);

__PACKAGE__->has_many(
    'peers',
    'Myriad::Schema::Peer',
    {
        'foreign.info_hash' => 'self.info_hash',
        'foreign.tracker' => 'self.tracker'
    }
);

__PACKAGE__->resultset_class('Myriad::Schema::ResultSet::Torrent');

1;
