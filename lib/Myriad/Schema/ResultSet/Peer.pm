package Myriad::Schema::ResultSet::Peer;

use strict;
use warnings;

use base qw{ DBIx::Class::ResultSet };

use Myriad::Schema::Peer;

use Carp;

sub active {
    my ($self) = @_;

    # TODO Centralized configuration of announce interval.

    my $type = $self->result_source->storage->sqlt_type;

    my $modified;
    if($type eq 'MySQL') {
        $modified = q{> DATE_SUB(NOW(), INTERVAL 2400 SECOND)};
    } elsif($type eq 'PostgreSQL') {
        $modified = q{> now() - interval '2400 seconds'};
    } elsif($type eq 'SQLite') {
        $modified = q{> datetime(strftime('%s', 'now') - 2400, 'unixepoch')};
    } else {
        carp "Unrecognized database driver, using application time";
        $modified = sprintf('> %d', time() - 2400);
    }

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
