use strict;
use warnings;
use utf8;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Myriad',
  VERSION_FROM => 'lib/Myriad.pm',
  ABSTRACT     => 'A Perl and DBIx::Class-based BitTorrent tracker',
  AUTHOR       => 'Jan Tore Morken <dist@jantore.net>',
  LICENSE      => 'artistic_2',
  PREREQ_PM => {
    'Bencode'               => 0,
    'Carp'                  => 0,
    'Class::Accessor::Fast' => 0,
    'DBIx::Class'           => 0,
    'DateTime'              => 0,
    'Digest::SHA1'          => 0,
    'Exporter'              => 0,
    'IP::Country::Fast'     => 0,
    'Net::IP'               => 0,
    'NetAddr::IP'           => 0,
    'Path::Class'           => 0,
  },
  TEST_REQUIRES => {
    'Test::More' => 0,
  },
  test => {TESTS => 't/*.t t/*/*.t'}
);
