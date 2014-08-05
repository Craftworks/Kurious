package Kurious::Plugin::FormValidator::Lite;

use Kurious::Base 'Mojolicious::Plugin';
use FormValidator::Lite;
use HTTP::AcceptLanguage;

my $languages;
my $message_data;

sub register {
    my ($self, $app, $conf) = @_;

    $conf = $app->config('validator') if $app->config('validator');

    # load constraints
    if ( ref $conf->{'constraints'} eq 'ARRAY' ) {
        FormValidator::Lite->load_constraints(@{ $conf->{'constraints'} });
    }

    $languages = $conf->{'languages'} || [ 'en' ];
    $message_data = $conf->{'message_data'};

    $app->hook('around_action' => \&_new);

    # register helper
    $app->helper('validate'  => \&validate);
    $app->helper('validator' => \&validator);
    $app->helper('validator_error_messages' => \&error_messages);
}

sub _new {
    my ($next, $c, $action, $last) = @_;

    state $default_language = $c->config('default_language');

    my $accept_language = HTTP::AcceptLanguage->new($c->req->headers->accept_language);
    my $lang = $accept_language->match(@$languages)
            || $default_language || 'en';

    my $validator = FormValidator::Lite->new($c->req->params);
    $validator->load_function_message($lang);
    $validator->set_message_data($message_data->{ $lang });
    $c->stash('validator' => $validator);

    return $next->();
}

sub validate {
    my ($c, @args) = @_;
    Carp::croak('validation rules are not specified at '. ref $c)
        unless @args;
    $c->stash('validator')->check(@args);
}

sub validator {
    shift->stash('validator');
}

sub error_messages {
    my $c = shift;

    my $validator = $c->stash('validator');

    while (my ($name, $errors) = each %{ $validator->errors }) {
        $validator->{'_error_messages'}{ $name }
            = $validator->get_error_messages_from_param($name);
    }

    $validator->{'_error_messages'} || +{};
}

1;
