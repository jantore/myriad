package Myriad::Catalyst::Controller;

use strict;
use warnings;

use base qw/Catalyst::Controller/;

sub announce : Path('/announce') {
    my ($self, $c) = @_;

    my $tracker_model = $self->config('tracker_model') || 'Myriad';
    my $tracker_host  = $self->config('tracker_host')  || $c->request->uri->host;

    my $m = $c->model( $tracker_model );
    $c->error('Tracker model missing or incorrect') and return unless defined $m;

    my $tracker = $m->resultset('Tracker')->active->find( $tracker_host ); 
    $c->error('No tracker for this host') and return unless defined $tracker;

    my %params = %{ $c->request->params };
    $params{'ip'} ||= $c->request->address;
    
    $c->stash->{bdata} = $tracker->announce( %params );
}

sub scrape : Path('/scrape') {
    my ($self, $c) = @_;

    # TODO Not repeat yourself.
    my $tracker_model = $self->config('tracker_model') || 'Myriad';
    my $tracker_host  = $self->config('tracker_host')  || $c->request->uri->host;

    my $m = $c->model( $tracker_model );
    $c->error('Tracker model missing or incorrect') and return unless defined $m;

    my $tracker = $m->resultset('Tracker')->active->find( $tracker_host );
    $c->error("No tracker for this host") and return unless defined $tracker;

    my %params = %{ $c->request->params };
    
    $c->stash->{bdata} = $tracker->scrape( %params );
}

1;
