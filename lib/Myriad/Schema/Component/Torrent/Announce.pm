package Myriad::Schema::Component::Torrent::Announce;

use strict;
use warnings;

use base qw{ DBIx::Class };

use Myriad::Util qw{ berror };
use NetAddr::IP;

sub announce {
    my $self = shift;
    my %params = @_;


    ###
    # Set up attributes that would be used for both update and create.
    ##
    my $attributes = {
        address    => $params{'ip'},
        port       => $params{'port'},
        downloaded => $params{'downloaded'},
        uploaded   => $params{'uploaded'},
        remaining  => $params{'left'},
        modified   => \q{NOW()},
    };


    ###
    # Update or create the peer entry.
    ##
    my $peer = $self->peers->find({ 'peer_id' => $params{'peer_id'} });

    if( defined $peer ) {
        # Verify announce key against peer secret. If the peer has no secret,
        # use IP address for verification.

        if( defined $peer->secret ) {
            return berror('Invalid key') unless( defined($params{'key'}) and $params{'key'} eq $peer->secret );
        } else {
	    return berror('Request IP does not match peer IP') unless( NetAddr::IP->new($params{'ip'}) == $peer->address );
        }

        if( defined($params{'event'}) ) {
            $attributes->{'state'} = Myriad::Schema::Peer::STOPPED if $params{'event'} eq 'stopped';
            $attributes->{'state'} = Myriad::Schema::Peer::STARTED if $params{'event'} eq 'started';
        }

        $peer->update( $attributes );
    } else {
        # No such peer exists. Create one if the client has just started,
        # fail otherwise.

        if( defined($params{'event'}) && $params{'event'} eq 'started' ) {
            $attributes->{'peer_id'} = $params{'peer_id'};
            $attributes->{'secret'} = $params{'key'} if defined $params{'key'};

            $self->peers->create( $attributes );
        } else {
            return berror('Unknown peer');
        }
    }


    ###
    # Increase the completion count if client has sent a 'completed' event.
    ##
    if( defined($params{'event'}) && $params{'event'} eq 'completed' ) {
        $self->update({ 'num_completes' => \q{num_completes + 1} });
    }


    ###
    # Pass on control to next component in chain.
    ##
    return $self->next::method( %params );
}

1;
