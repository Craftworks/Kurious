package Kurious::Plugin::Container;

use Kurious::Base 'Mojolicious::Plugin';
use Carp;
use UNIVERSAL::require;

sub register {
    my ($self, $app, $conf) = @_;

    $app->helper('instance' => sub {
        state %instances;
        my ($controller, $class, @args) = @_;

        if ( !$instances{ $class } || @args ) {
            $class->use or croak $@;
            $instances{ $class } = $class->new(@args);
        }

        return $instances{ $class };
    });
}

1;
