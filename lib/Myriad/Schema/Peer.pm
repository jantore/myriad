package Myriad::Schema::Peer;

use base qw{ DBIx::Class };

use NetAddr::IP;

use constant {
    STOPPED => 0,
    STARTED => 1,
};

__PACKAGE__->load_components(qw{
    +Myriad::Schema::Component::Peer::CountryLookup
    +Myriad::Schema::Component::Peer::Rate
    +Myriad::Schema::Component::Timestamp
    Core
});

__PACKAGE__->table('Peer');

# TODO Configure data types, sizes and other details for SQL deployment.
__PACKAGE__->add_columns(
    'peer_id' => {
        data_type   => 'blob',
        size        => 20,
        is_nullable => 0,
    },
    'info_hash' => {
        data_type   => 'blob',
        size        => 20,
        is_nullable => 0,
    },
    'tracker' => {
        data_type   => 'varchar',
        size        => 128,
        is_nullable => 0,
    },
    'created' => {
        data_type   => 'integer',
        size        => 10,
        is_nullable => 0,
    },
    'modified' => {
        data_type   => 'integer',
        size        => 10,
        is_nullable => 0,
    },
    'port' => {
        data_type   => 'integer',
        size        => 5,
        is_nullable => 0,
    },
    'address' => {
        data_type   => 'varchar',
        size        => 39,
        is_nullable => 0,
    },
    'downloaded' => {
        data_type   => 'integer',
        is_nullable => 0,
        default_value => 0,
    },
    'uploaded' => {
        data_type     => 'integer',
        is_nullable   => 0,
        default_value => 0,
    },
    'remaining' => {
        data_type     => 'integer',
        is_nullable   => 0,
    },
    'downrate' => {
        data_type     => 'float',
        default_value => 0.0,
    },
    'uprate' => {
        data_type     => 'float',
        default_value => 0.0,
    },
    'state' => {
        data_type     => 'integer',
        size          => 1,
        is_nullable   => 0,
        default_value => STARTED,
    },
    'secret' => {
        data_type     => 'blob',
        size          => 64,
        is_nullable   => 1,
        default_value => undef,
    },
);
 
__PACKAGE__->belongs_to(
    'torrent',
    'Myriad::Schema::Torrent',
    {
        'foreign.info_hash' => 'self.info_hash',
        'foreign.tracker' => 'self.tracker',
    }
);

__PACKAGE__->set_primary_key('peer_id', 'info_hash', 'tracker');

__PACKAGE__->resultset_class('Myriad::Schema::ResultSet::Peer');

__PACKAGE__->inflate_column(
    'address',
    {
        inflate => sub { return NetAddr::IP->new(shift); },
        deflate => sub {
            my $a = shift;
            return ref($a) ? $a->addr : $a;
        }
    }
);

1;
