package Myriad::Schema::Component::Torrent::GetPeers;

use base qw{ DBIx::Class };

sub scrape {
    my $self = shift;

    return {
        'complete'   => $self->peers->active->complete->count,
        'incomplete' => $self->peers->active->incomplete->count,
        'downloaded' => $self->num_completes,
    }
}

1;
