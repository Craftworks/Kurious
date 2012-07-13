package Kurious::Plugin::Architecture;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
    my ($self, $app, $conf) = @_;

    for my $component (qw(Interface Accessor Driver)) {
        $app->helper(lc $component => sub {
            my ($self, $name) = @_;

            my $app_class = $app->home->app_class;
            my $class = "$app_class\::$component\::$name";

            local $Carp::CarpLevel = 3;
            $self->instance($class);
        });

        no strict 'refs';
        *{"Kurious::$component\::app"} = sub { $app };
    }
}

1;
