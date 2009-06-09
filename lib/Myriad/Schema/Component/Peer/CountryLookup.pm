package Myriad::Schema::Component::Peer::CountryLookup;

use strict;
use warnings;

use base qw{ DBIx::Class };

use Carp;

__PACKAGE__->mk_classdata('ipcountry');


###
# Attempt to load IP::Country::Fast, but don't fall apart if it's not
# installed.
##
eval { require IP::Country::Fast; };
unless($@) {
    __PACKAGE__->ipcountry( IP::Country::Fast->new() );
}


sub country {
    my $self = shift;

    if(defined $self->ipcountry) {
        return $self->ipcountry->inet_atocc( $self->address->addr );
    } else {
        carp "No IP::Country::Fast instance loaded, module not installed?";
        return;
    }
}

1;
