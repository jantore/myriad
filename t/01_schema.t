use strict;
use Test::More tests => 4;

use Myriad::Schema;

my $schema = Myriad::Schema->connect;
isa_ok($schema, 'Myriad::Schema');

isa_ok($schema->resultset('Tracker'), 'Myriad::Schema::ResultSet::Tracker');
isa_ok($schema->resultset('Torrent'), 'Myriad::Schema::ResultSet::Torrent');
isa_ok($schema->resultset('Peer'),    'Myriad::Schema::ResultSet::Peer'   );
