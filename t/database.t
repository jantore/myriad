#!/usr/bin/env perl

use strict;
use warnings;

use lib 't/lib';

use Test::More;

use Myriad::Test::Schema;

for (qw{ mysql postgresql sqlite }) {
    my $dsn = sprintf('MYRIAD_%s_DSN', uc);
    my $user = sprintf('MYRIAD_%s_USER', uc);
    my $password = sprintf('MYRIAD_%s_PASSWORD', uc);

    subtest "database engine: $_" => sub {
        if(not $ENV{$dsn}) {
            plan skip_all => 'no DSN for database in environment';
        }

        my @info = ($ENV{$dsn});

        if($ENV{$user}) {
            push(@info, $ENV{$user});
            push(@info, $ENV{$password}) if $ENV{$password};
        }

        Myriad::Test::Schema->run(@info);
    }
}

done_testing;
