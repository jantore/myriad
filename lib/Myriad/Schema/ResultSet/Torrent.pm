package Myriad::Schema::ResultSet::Torrent;

use base qw{ DBIx::Class::ResultSet };

sub active {
    return shift->search({ active => 1 });
}

sub num_completes {
    return shift->get_column('num_completes')->sum;
}

sub transferred_bytes {
    return shift->search(
        {},
        {
            'select' => [ { 'sum' => 'size * num_completes' } ],
            'as'     => [ 'total_transfer' ],
        }
    )->first->get_column('total_transfer');
}

1;
