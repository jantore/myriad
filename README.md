# NAME

Myriad - a DBIx::Class-based BitTorrent tracker

# SYNOPSIS

    my $myriad = Myriad::Schema->connect('dbi:mysql:database=tracker', '', '');
    my $peers = $myriad->announce({});

# DESCRIPTION

Myriad is a BitTorrent tracker backend that is suitable for use with
Perl-based web application frameworks like [Catalyst](https://metacpan.org/pod/Catalyst) or [Mojolicious](https://metacpan.org/pod/Mojolicious).

# AUTHOR

Jan Tore Morken <dist@jantore.net>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018-2014 by Jan Tore Morken.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
