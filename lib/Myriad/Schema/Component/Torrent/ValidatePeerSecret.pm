package Myriad::Schema::Component::Torrent::ValidatePeerSecret;

use strict;
use warnings;

use base qw{ DBIx::Class };

sub announce {
    my $self = shift;
    my %params = @_;

    my $peer = $self->peers->find({ 'peer_id' => $params{'peer_id'} });

    if( defined $peer ) {

    }
}

1;
