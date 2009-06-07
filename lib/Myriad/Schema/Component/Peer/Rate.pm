package Myriad::Schema::Component::Peer::Rate;

use base qw{ DBIx::Class };

# TODO Ensure rate calculation works correctly when using the downloaded and
#      uploaded accessors.

sub store_column {
    my ($self, $column, $value) = @_;

    if( ($column eq 'downloaded' || $column eq 'uploaded') && defined($self->modified) ) {
        my $interval = time() - $self->modified;
        my $ratecol  = ($column eq 'downloaded') ? 'downrate' : 'uprate';
        my $rate     = $value - $self->get_column($column);
        $self->set_column($ratecol, $rate / $interval);
    }

    return $self->next::method($column, $value);
}

1;

# sub update {
#     my ($self, $values) = @_;

#     my $interval = time() - $self->modified;

#     unless($self->is_column_changed('downrate')) {
#         my $downdelta = $values->{'downloaded'} - $self->downloaded;
#         $values->{'downrate'} = $downdelta / $interval;
#     }

#     unless($self->is_column_changed('uprate')) {
#         my $updelta = $values->{'uploaded'} - $self->uploaded;
#         $values->{'uprate'}   = $updelta   / $interval;
#     }

#     return $self->next::method($values);
# }

# sub downloaded {
#     my ($self, $value) = @_;

#     my $interval = time() - $self->modified;

#     unless($self->is_column_changed('downloaded')) {
#         $self->downrate( ($value - $self->{'downloaded'}
#     }

#     return $self->next::method($value);
# }
