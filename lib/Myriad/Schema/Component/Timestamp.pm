package Myriad::Schema::Component::Timestamp;

use base qw{ DBIx::Class };

sub insert {
    my ($self) = @_;

    $self->created(time()) unless defined $self->created;
    return $self->next::method(@_);
}

sub update {
    my ($self, $values) = @_;

    $values{'modified'} = time() unless defined $values{'modified'};
    return $self->next::method($values);
}

1;
