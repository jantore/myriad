package Myriad::Test::Schema;

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Myriad::Schema;
use Myriad::Test::Tracker;

use Carp;

BEGIN {
    $SIG{__WARN__} = \&Carp::confess
}

sub run {
    my $testclass = shift;
    my $class = 'Myriad::Schema';

    my @connect_info = @_;

    use_ok $class;
    can_ok $class => qw{ connect };

    subtest 'live database' => sub {
        if(not @connect_info) {
            plan skip_all => 'no connect info for database';
        }

        my $schema = $class->connect(@connect_info);
        isa_ok $schema, $class;

        can_ok $schema => qw{ deploy resultset now };

        isa_ok($schema->now, 'DateTime');

        $schema->deploy;
        dies_ok { $schema->deploy } 'deploying twice should fail';

        Myriad::Test::Tracker->run($schema);

        done_testing;
    };

    done_testing;
}

sub _populate {
    my ($schema) = @_;

    
}

1;
