package Myriad::Schema::Component::Torrent::ValidateAnnounce;

use base qw/DBIx::Class/;

use Myriad::Util qw/berror/;

sub announce {
    my $self = shift;
    my %params = @_;

    my $peer = $self->peers->find({ 'peer_id' => $params{'peer_id'} });

    if( defined $peer ) {

    }
}

1;
