package Myriad::Schema::Component::Timestamp;

use base qw{ DBIx::Class };

sub insert {
    my $self = shift;

    $self->created(time());
    return $self->next::method(@_);
}

sub update {
    my $self = shift;

    $self->modified(time());
    return $self->next::method(@_);
}

1;
