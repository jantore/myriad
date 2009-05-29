package Myriad::Schema::Component::Peer::CountryLookup;

use base qw/DBIx::Class/;

use IP::Country::Fast;

__PACKAGE__->mk_classdata( 'ipcountry' );
__PACKAGE__->ipcountry( IP::Country::Fast->new );

sub country {
    my $self = shift;
    return $self->ipcountry->inet_atocc( $self->address->addr );
}
