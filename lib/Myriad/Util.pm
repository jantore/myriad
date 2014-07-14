package Myriad::Util;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw{ berror };

sub berror {
    return { 'failure reason' => shift };
}

1;
