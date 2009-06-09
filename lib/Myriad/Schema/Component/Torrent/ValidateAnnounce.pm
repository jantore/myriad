package Myriad::Schema::Component::Torrent::ValidateAnnounce;

use strict;
use warnings;

use base qw{ DBIx::Class };

use Myriad::Util qw{ berror };

sub announce {
    my $self = shift;
    my %params = @_;

    foreach my $p ('ip', 'peer_id', 'port', 'downloaded', 'uploaded', 'left') {
        return berror('Missing parameter: ' . $p) unless defined $params{$p};
    }
    return berror('Invalid peer ID (length ' . length($params{'peer_id'}) . ')') if length($params{'peer_id'}) > 20;

    return berror('Invalid port number') unless ( $params{'port'} =~ /^\d{1,5}$/ && $params{'port'} <= 65535 );
    return berror('Invalid download amount') unless $params{'downloaded'} =~ /^\d{1,20}$/;
    return berror('Invalid uploaded amount') unless $params{'uploaded'} =~ /^\d{1,20}$/;
    return berror('Invalid remaining amount') unless ( $params{'left'} =~ /^\d{1,20}$/ && $params{'left'} <= $self->size );
    return berror('Invalid numwant value') if defined $params{'numwant'} && $params{'numwant'} !~ /^\d*$/;

    return $self->next::method( %params );
}

1;
