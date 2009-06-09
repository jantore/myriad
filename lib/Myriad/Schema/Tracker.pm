package Myriad::Schema::Tracker;

use strict;
use warnings;

use base qw{ DBIx::Class };

use Carp;
use Net::IP;
use Myriad::Util qw{ berror };

__PACKAGE__->load_components( qw{
    Core
});

__PACKAGE__->table('Tracker');

__PACKAGE__->add_columns(
    'host' => {
        data_type     => 'varchar',
        size          => 128,
        is_nullable   => 0,
    },
    'title' => {
        data_type     => 'varchar',
        size          => 128,
        is_nullable   => 0,
    },
    'active' => {
        data_type     => 'integer',
        size          => 1,
        is_nullable   => 0,
        default_value => 1,
    },
    'allow_ipv4' => {
        data_type     => 'integer',
        size          => 1,
        is_nullable   => 0,
        default_value => 1,
    },
    'allow_ipv6' => {
        data_type     => 'integer',
        size          => 1,
        is_nullable   => 0,
        default_value => 1,
    },
);

__PACKAGE__->set_primary_key('host');

__PACKAGE__->has_many('torrents', 'Myriad::Schema::Torrent', 'tracker');
__PACKAGE__->has_many('peers',    'Myriad::Schema::Peer',    'tracker');

__PACKAGE__->resultset_class('Myriad::Schema::ResultSet::Tracker');


sub announce {
    my $self = shift;
    my %params = @_;

    return berror('Missing info hash') unless defined $params{'info_hash'};

    ###
    # Validate IP address and check that we allow this address family.
    ##
    my $ipv = Net::IP::ip_get_version( $params{'ip'} );
    return berror('Invalid IP address') unless defined $ipv;

    return berror('IPv4 clients not allowed') if ( $ipv == 4 and not $self->allow_ipv4 );
    return berror('IPv6 clients not allowed') if ( $ipv == 6 and not $self->allow_ipv6 );

    ###
    # Pass announce on the torrent itself.
    ##
    my $torrent = $self->torrents->active->find({ 'info_hash' => $params{'info_hash'} });
    return berror('No such torrent') unless defined $torrent;

    my $bdata = $torrent->announce(%params);
    return $bdata if exists $bdata->{'failure reason'};

    # TODO Move these parameters to a configuration file.
    $bdata->{'interval'} = 1800;
    $bdata->{'min interval'} = 120;
    $bdata->{'tracker id'} = $self->host;
    return $bdata;
}

sub scrape {
    my $self = shift;
    my %params = @_;

    my $files = {};

    my $info_hash = $params{'info_hash'};

    foreach ( ref($info_hash) ? @{ $info_hash } : $info_hash ) {
        my $torrent = $self->torrents->active->find({ 'info_hash' => $_ });
        return berror('No torrent for given info hash') unless defined $torrent;
        $files->{ $_ } = $torrent->scrape();
    }

    return { 'files' => $files };
}

1;
