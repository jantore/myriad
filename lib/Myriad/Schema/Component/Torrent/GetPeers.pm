package Myriad::Schema::Component::Torrent::GetPeers;

use strict;
use warnings;

use base qw{ DBIx::Class };

sub announce {
    my $self = shift;
    my %params = @_;

    ###
    # Build list of peers to return. Two lists are built: one compact
    # that is really just an array of strings, and one that is an array
    # of hashes. If an IPv6 peer is discovered while building the list,
    # the compact list is ditched, else the compact one is used.
    ##
    my $peers = eval {
        my $rows = ( defined $params{'numwant'} && $params{'numwant'} < 500 ) ? $params{'numwant'} : 50;
        my @compact = ();
        my @normal = ();
        my $v6seen = 0;

        foreach my $peer ( $rows == 0 ? () : $self->peers->active->randomize->search({}, { rows => $rows }) ) {
            my $address = $peer->address;
            my $port = $peer->port;
            $v6seen ||= ($address->version == 6);

            # Make a compact record.
            #
            # If there's an IPv6 client in the response, stop adding compact
            # records, since they won't be used.
            push(@compact, pack("Nn", ($address->numeric)[0], $port)) unless $v6seen;


            # Make a normal record, which consists of a hash of peer info.
            #
            # Peer ID will be added unless the client asks us not to.
            push(@normal, {
                (
                    'ip'   => lc($peer->address->addr),
                    'port' => $peer->port
                ),
                $params{'no_peer_id'} ? () : ( 'peer id' => $peer->peer_id ),
             });
         }

        # Return a compact string or an arrayref.
        if( (defined $params{'compact'} && $params{'compact'} == 1) && not $v6seen ) {
            return join('', @compact);
        } else {
            return \@normal;
        }
    };


    ###
    # Construct the torrent-specific part of the tracker response.
    ##
    # TODO Can this be replaced with return $self->scrape()?
    return {
        'complete'   => $self->peers->active->complete->count,
        'incomplete' => $self->peers->active->incomplete->count,
        'peers'      => $peers,
    };
}

1;
