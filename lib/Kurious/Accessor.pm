package Kurious::Accessor;
use Mojo::Base -base;
sub log       { shift->app->log }
sub config    { shift->app->config }
sub accessor  { shift->app->accessor(@_) }
sub driver    { shift->app->driver(@_) }
1;
