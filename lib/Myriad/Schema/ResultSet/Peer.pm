package Myriad::Schema::ResultSet::Peer;

use base qw{ DBIx::Class::ResultSet };

sub active {
    my ($self) = @_;

    # TODO Centralized configuration of announce interval.
    # TODO This is MySQL specific. Replace this with application logic.
    return $self->search({
        state    => Myriad::Schema::Peer::STARTED,
        modified => \q{> DATE_SUB(NOW(), INTERVAL 2400 SECOND)},
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
