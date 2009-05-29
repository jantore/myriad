package Myriad::Schema::Peer;

use base qw{ DBIx::Class };

use NetAddr::IP;

use constant {
    STOPPED => 0,
    STARTED => 1,
};

__PACKAGE__->load_components(qw{
    +Myriad::Schema::Component::Peer::CountryLookup
    Core
});

__PACKAGE__->table('Peer');

# TODO Configure data types, sizes and other details for SQL deployment.
__PACKAGE__->add_columns(
    'peer_id',
    'info_hash',
    'tracker',
    'created',
    'modified',
    'port',
    'address',
    'downloaded',
    'uploaded',
    'remaining',
    'downrate',
    'uprate',
    'state',
    'secret',
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
