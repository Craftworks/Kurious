package Kurious;

use Mojo::Base 'Mojolicious';
use Time::HiRes 'time';
use Kurious::Log;

sub import {
    strict->import;
    warnings->import('FATAL' => 'all');
    feature->import(':5.10');
    shift->SUPER::import(@_);
}

sub startup {
    my $self = shift;

    $self->log(Kurious::Log->new);

    push @{ $self->plugins->namespaces }, 'Kurious::Plugin';
    $self->plugin('HostConfig');
    $self->plugin('Container');
    $self->plugin('Architecture');
}

my $time;
BEGIN { $time = time }
END {
    my $elapsed = time - $time;
    __PACKAGE__->log->info(sprintf "Process took %.3f sec\n\n\n", $elapsed);
}

1;
