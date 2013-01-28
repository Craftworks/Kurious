package Kurious::Driver;
use Kurious::Base -base;
sub log       { shift->app->log }
sub d         { shift->app->log->dump(@_) }
sub config    { shift->app->config }
1;
