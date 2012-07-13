package Kurious::Driver;
use Mojo::Base -base;
sub log       { shift->app->log }
sub config    { shift->app->config }
1;
