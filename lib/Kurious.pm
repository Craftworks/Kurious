package Kurious;

use Kurious::Base 'Mojolicious';
use Time::HiRes 'time';
use Kurious::Log;

sub import {
    strict->import;
    warnings->import('FATAL' => 'all');
    feature->import(':5.10');
    shift->SUPER::import(@_);
}

my $log = __PACKAGE__->log;
sub startup {
    my $self = shift;

    $self->log(Kurious::Log->new);
    $log = $self->log;

    push @{ $self->plugins->namespaces }, 'Kurious::Plugin';
    $self->plugin('HostConfig');
    $self->plugin('Container');
    $self->plugin('Architecture');

    $self->startup_routes;

    $self->types->type('json' => 'application/json; charset=utf-8');
}

sub startup_routes {
    my $self = shift;

    my $app_class = $self->home->app_class;

    my $router_class = "$app_class\::Routes";
    Mojo::Loader->load($router_class);

    my $routes = $self->routes;
    $routes->namespace("$app_class\::Controller");
    $router_class->startup($routes);
}

my $time;
BEGIN { $time = time }
END {
    my $elapsed = time - $time;
    $log->info(sprintf "Process took %.3f sec\n\n\n", $elapsed);
}

1;
