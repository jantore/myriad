package Myriad::Schema::ResultSet::Peer;

use base qw{ DBIx::Class::ResultSet };

sub active {
    my ($self) = @_;

    # TODO Centralized configuration of announce interval.
    return $self->search({
        state    => Myriad::Schema::Peer::STARTED,
        modified => { '>' => time() - 2400 },
    });
}

sub complete {
    return shift->search({ remaining => 0});
}

sub incomplete {
    return shift->search({ remaining => { '>' => 0 } });
}

sub randomize {
    my $self = shift;

    ###
    # We wish to randomize on the database side, so we need to determine
    # what random function we want to use.
    ##
    my $type = $self->result_source->storage->sqlt_type;

    my $random;
    if($type eq 'MySQL') {
        $random = 'RAND()';
    } elsif($type eq 'PostgreSQL' || $type eq 'SQLite') {
        $random = 'RANDOM()';
    } else {
        carp "Unrecognized database driver, no randomizing done";
        return $self;
    }

    return $self->search({}, { order_by => $random });
}

sub descending {
    my ($self, $column) = @_;

    return $self->search({}, { order_by => sprintf("%s DESC", $column) });
}

sub ascending {
    my ($self, $column) = @_;

    return $self->search({}, { order_by => sprintf("%s ASC", $column) });
}

sub swarm_speed {
    return 0.5 * shift->search(
        {},
        {
            'select' => [ { 'sum' => 'uprate + downrate' } ],
            'as'     => [ 'swarm_speed' ],
        }
    )->first->get_column('swarm_speed');
}

1;
