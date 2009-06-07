use strict;
use Test::More;

use File::Temp ();
use Myriad::Schema;

BEGIN {
    eval { require DBD::SQLite; };
    if($@) {
        plan(skip_all => 'No DBD::SQLite');
    } else {
        plan(tests => 15);
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

can_ok($tracker, "torrents", "peers", "announce");

my $bdata = $tracker->announce;
ok(defined $bdata->{'failure reason'}, "Empty announce returns failure reason");

###
# Test torrent functionality
##

my $torrent = $tracker->torrents->create({
    info_hash => pack("h*", 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF),
    size => 123456789,
    title => 'Example torrent',
});
isa_ok($torrent, "Myriad::Schema::Torrent");
is($torrent->tracker->host, $tracker->host, "Tracker is set and the same");
ok(defined $torrent->created && $torrent->created > 0, "Torrent timestamp set");

ok($tracker->torrents->find({ info_hash => pack("h*", 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)}), "Can look up torrent by info hash");

my @a = $tracker->torrents;
is(scalar(@a), 1, "One torrent on tracker");

###
# Test peer functionality
##

my $peer1 = $torrent->peers->create({
    peer_id   => 'aaaaaaaaaaaaaaaaaaaa',
    modified  => time() - 3000,
    port      => 12345,
    address   => '127.0.0.1',
    remaining => 123456789,
});

my $peer2 = $torrent->peers->create({
    peer_id   => 'bbbbbbbbbbbbbbbbbbbb',
    port      => 12345,
    address   => '127.0.0.2',
    modified  => undef,
    remaining => 123456789,
});

@a = $torrent->peers->all;
is(scalar(@a), 2, "Two peers in total");

@a = $torrent->peers->active->all;
is(scalar(@a), 1, "Only one active peer");

$peer1->downloaded(1000);
$peer1->update();

@a = $torrent->peers->active->all;
is(scalar(@a), 2, "Two active peers");
