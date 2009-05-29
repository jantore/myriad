package Myriad::Util;

use Exporter 'import';
@EXPORT_OK = qw{ berror };

sub berror {
    return { 'failure reason' => shift };
}

1;
