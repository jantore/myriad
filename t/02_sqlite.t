use strict;
use Test::More;

use File::Temp ();
use Myriad::Schema;

BEGIN {
    eval { require DBD::SQLite; };
    if($@) {
        plan(skip_all => 'No DBD::SQLite');
    } else {
        plan(tests => 7);
    }
}

my $tmp = File::Temp->new( SUFFIX => '.db' );

my $schema = Myriad::Schema->connect("dbi:SQLite:" . $tmp);
$schema->deploy();


###
# Test tracker functionality
##

ok($schema->resultset('Tracker')->create({
    host   => 'tracker.example.org',
    title  => 'Example tracker',
    active => 1,
}), "Can create first tracker");

ok($schema->resultset('Tracker')->create({
    host   => 'tracker2.example.org',
    title  => 'Second example tracker',
    active => 0,
}), "Can create second, inactive tracker");


my @a = $schema->resultset('Tracker')->all;
is(scalar(@a), 2, "Two trackers in resultset");

@a = $schema->resultset('Tracker')->active->all;
is(scalar(@a), 1, "One tracker in active resultset");

my $tracker = $schema->resultset('Tracker')->find('tracker.example.org');
isa_ok($tracker, "Myriad::Schema::Tracker");
is($tracker->active, 1, "Tracker is active");

can_ok($tracker, "announce");

###
# Test torrent functionality
##
# TODO Add some tests.


###
# Test peer functionality
##
# TODO Add some tests.
