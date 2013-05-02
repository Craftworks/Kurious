package Kurious::Controller;
use Kurious::Base 'Mojolicious::Controller';
sub log { shift->app->log }
sub d   { shift->app->log->dump(@_) }

sub action_path {
    my $self = shift;

    my $caller = (caller 3)[3];
    my $app_class = $self->app->home->app_class;
    my $action = substr $caller, length("$app_class\::Controller::");
    $action =~ s{::}{/}go;

    return lc $action;
}

1;
