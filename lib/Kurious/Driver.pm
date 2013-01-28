package Kurious::Driver;
use Mojo::Base -base;
sub log       { shift->app->log }
sub d         { shift->app->log->dump(@_) }
sub config    { shift->app->config }
1;
