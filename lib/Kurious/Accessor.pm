package Kurious::Accessor;

use Kurious::Base -base;
use Data::Recursive::Encode;

sub log       { shift->app->log }
sub d         { shift->app->log->dump(@_) }
sub config    { shift->app->config }
sub accessor  { shift->app->accessor(@_) }
sub driver    { shift->app->driver(@_) }

sub enable_utf8 {
    my ($self, $rows) = @_;
    Data::Recursive::Encode->decode_utf8($rows);
}

1;
