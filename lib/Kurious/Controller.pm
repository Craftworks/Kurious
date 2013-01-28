package Kurious::Controller;
use Mojo::Base 'Mojolicious::Controller';
sub log { shift->app->log }
sub d   { shift->app->log->dump(@_) }

1;
