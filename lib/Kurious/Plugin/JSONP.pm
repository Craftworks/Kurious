package Kurious::Plugin::JSONP;

use Kurious::Base 'Mojolicious::Plugin';
use JSON::XS;

has 'allow_callback' => 0;
has 'callback_param' => 'callback';

sub register {
    my ($self, $app, $conf) = @_;

    %$self = (%$self, %$conf);

    my $json = JSON::XS->new->ascii(1);
    my $callback_param = $self->allow_callback ? $self->callback_param : undef;

    # add new renderer
    $app->helper('render_jsonp' => sub {
        my ($c, $data, @args) = @_;

        my $callback = $callback_param ? $c->param($callback_param) : undef;
        $self->validate_callback_param($callback) if $callback;

        my $json_text = $json->encode($data);
        $json_text =~ s/([<>\/\+])/sprintf("\\u%04x",ord($1))/eg;

        my $output = $callback ? "$callback($json_text)" : $json_text;

        $c->render_text($output, @args);
    });
}

sub validate_callback_param {
    my ($self, $param) = @_;
    $param =~ /^[a-zA-Z0-9\.\_\[\]]+$/o
        or die qq{Invalid callback parameter "$param"};
}

1;
