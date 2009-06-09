package Myriad::Schema::ResultSet::Tracker;

use strict;
use warnings;

use base qw{ DBIx::Class::ResultSet };

sub active {
    return shift->search({ active => 1 });
}

1;
