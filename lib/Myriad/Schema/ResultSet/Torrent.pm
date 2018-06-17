package Myriad::Schema::ResultSet::Torrent;

use strict;
use warnings;

use base qw{ DBIx::Class::ResultSet };

sub active {
    return shift->search({ active => 1 });
}

sub descending {
    return shift->search({}, { order_by => { -desc => shift } });
}

sub ascending {
    return shift->search({}, { order_by => { -asc => shift } });
}

sub num_completes {
    return shift->get_column('num_completes')->sum || 0;
}

sub transferred_bytes {
    return shift->search(
        {},
        {
            'select' => [ { 'sum' => 'size * num_completes' } ],
            'as'     => [ 'total_transfer' ],
        }
    )->first->get_column('total_transfer') || 0;
}

1;
