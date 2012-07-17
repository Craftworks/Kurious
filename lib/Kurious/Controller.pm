package Kurious::Controller;
use Mojo::Base 'Mojolicious::Controller';
sub log { shift->app->log }
1;
