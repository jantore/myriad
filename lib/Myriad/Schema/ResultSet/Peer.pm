package Myriad::Schema::ResultSet::Peer;

use strict;
use warnings;

use base qw{ DBIx::Class::ResultSet };

use Myriad::Schema::Peer;

use Carp;

sub active {
    my ($self) = @_;

    # TODO Centralized configuration of announce interval.
    my $modified = {
        mysql      => q{> DATE_SUB(NOW(), INTERVAL 2400 SECOND)},
        postgresql => q{> EXTRACT(EPOCH FROM (NOW() - INTERVAL '2400 seconds'))},
        sqlite     => q{> strftime('%s', 'now') - 2400},
    }->{lc $self->result_source->storage->sqlt_type};

    return $self->search({
        state    => Myriad::Schema::Peer::STARTED,
        modified => \$modified,
    });
}

sub complete {
    return shift->search({ remaining => 0});
}

sub incomplete {
    return shift->search({ remaining => { '>' => 0 } });
}

sub randomize {
    my ($self) = @_;

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
