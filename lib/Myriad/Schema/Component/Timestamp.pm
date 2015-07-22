package Myriad::Schema::Component::Timestamp;

use strict;
use warnings;

use base qw{ DBIx::Class };

sub insert {
    my $self = shift;

    my $now = {
        mysql      => q{ UNIX_TIMESTAMP()          },
        postgresql => q{ EXTRACT(EPOCH FROM NOW()) },
        sqlite     => q{ STRFTIME('%s', 'now')     },
    }->{lc $self->result_source->storage->sqlt_type};

    $self->created(\$now)  if not defined $self->created;
    $self->modified(\$now) if not defined $self->modified;

    return $self->next::method(@_);
}

sub update {
    my $self = shift;

    my $now = {
        mysql      => q{ UNIX_TIMESTAMP()          },
        postgresql => q{ EXTRACT(EPOCH FROM NOW()) },
        sqlite     => q{ STRFTIME('%s', 'now')     },
    }->{lc $self->result_source->storage->sqlt_type};

    $self->modified(\$now);

    return $self->next::method(@_);
}

1;
