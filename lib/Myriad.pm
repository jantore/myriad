package Myriad;

use strict;
use version; our $VERSION = version->declare("v0.0.1");

1;
__END__

=head1 NAME

Myriad - a DBIx::Class-based BitTorrent tracker

=head1 SYNOPSIS

  my $myriad = Myriad::Schema->connect('dbi:mysql:database=tracker', '', '');
  my $peers = $myriad->resultset('Tracker')
      ->active
      ->find('tracker.example.net')
      ->announce({});

=head1 DESCRIPTION

Myriad is a BitTorrent tracker backend that is suitable for use with
Perl-based web application frameworks like L<Catalyst> or L<Mojolicious>.

=head1 AUTHOR

Jan Tore Morken <dist@jantore.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2008-2015 by Jan Tore Morken.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
