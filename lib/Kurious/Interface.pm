package Kurious::Interface;
use Kurious::Base -base;
sub log       { shift->app->log }
sub d         { shift->app->log->dump(@_) }
sub config    { shift->app->config }
sub interface { shift->app->interface(@_) }
sub accessor  { shift->app->accessor(@_) }
1;
