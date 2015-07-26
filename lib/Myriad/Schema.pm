package Myriad::Schema;

use strict;

use base qw{ DBIx::Class::Schema };

__PACKAGE__->load_classes(qw{ Tracker Torrent Peer });

use DateTime;

sub now {
    my $storage = shift->storage;

    my $q = {
        mysql      => q{ SELECT UNIX_TIMESTAMP()          },
        postgresql => q{ SELECT EXTRACT(EPOCH FROM NOW()) },
        sqlite     => q{ SELECT STRFTIME('%s', 'now')     },
    }->{lc $storage->sqlt_type};

    return DateTime->from_epoch(epoch => $storage->dbh_do(
        sub {
            my ($s, $dbh) = @_;
            $dbh->selectrow_arrayref($q)->[0];
        }
    ));
}

sub connection {
    my ($self, @info) = @_;
    return $self if !@info;

    my $schema = $self->next::method(@info);

    # SQL::Translator doesn't support index sizes required by MySQL
    # for indexing blob columns. Therefore we dynamically change the
    # data type to binary if we're running on MySQL. This is only
    # important when deploying the schema.
    my $bintype = {
        mysql      => 'binary',
        postgresql => 'bytea',
        sqlite     => 'blob',
    }->{lc $schema->storage->sqlt_type};

    $schema->source('Torrent')->add_column(
        '+info_hash' => { data_type => $bintype }
    );

    $schema->source('Peer')->add_column(
        '+peer_id' => { data_type => $bintype }
    );

    $schema->source('Peer')->add_column(
        '+info_hash' => { data_type => $bintype }
    );

    return $schema;
}

sub populate_test {
    my ($schema) = @_;

    my $tracker = $schema->resultset('Tracker')->create({
        host => 'tracker.example.net',
        title => 'Test Tracker',
        active => 1
    });

    my $torrent = $tracker->torrents->create({
        info_hash => '00000000000000000000',
        size      => 1000,
        title     => 'Test Torrent',
        active    => 1,
    });

    my $seeder = $torrent->peers->create({
        peer_id   => 'TESTSEEDER',
        port      => 12345,
        address   => '1.1.1.1',
        remaining => 0,
    });

    my $leecher = $torrent->peers->create({
        peer_id   => 'TESTLEECHER',
        port      => 54321,
        address   => '2.2.2.2',
        remaining => 1000,
    });
}

1;
