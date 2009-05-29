package Myriad::Schema::ResultSet::Tracker;

use base qw{ DBIx::Class::ResultSet };

sub active {
    return shift->search({ active => 1 });
}

1;
