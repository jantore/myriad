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
    return shift->search({}, { order_by => 'RAND()' });
}

sub descending {
    return shift->search({}, { order_by => sprintf("%s DESC", shift) });
}

sub ascending {
    return shift->search({}, { order_by => sprintf("%s ASC", shift) });
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
