package Kurious::Interface;
use Mojo::Base -base;
sub log       { shift->app->log }
sub config    { shift->app->config }
sub interface { shift->app->interface(@_) }
sub accessor  { shift->app->accessor(@_) }
1;
