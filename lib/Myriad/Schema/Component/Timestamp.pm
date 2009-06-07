package Myriad::Schema::Component::Timestamp;

use base qw{ DBIx::Class };

sub insert {
    my ($self) = @_;

    my $time = time();
    $self->created($time)  unless defined $self->created;
    $self->modified($time) unless defined $self->modified;

    return $self->next::method(@_);
}

sub update {
    my ($self, $values) = @_;

    $values->{'modified'} = time() unless defined $values->{'modified'};

    return $self->next::method($values);
}

1;
