package Kurious::Plugin::JSON::XS;

use Mojo::Base 'Mojolicious::Plugin';
use JSON::XS;

sub register {
    my ($self, $app, $conf) = @_;

    my $json = JSON::XS->new->ascii(1);

    # replace default json handler
    $app->renderer->add_handler('json' => sub {
        my ($self, $c, $output, $options) = @_;
        $$output = $json->encode($options->{'json'});
    });
}

1;
