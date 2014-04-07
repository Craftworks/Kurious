package Kurious::Plugin::Plack::Middleware::Session;

use Kurious::Base 'Mojolicious::Plugin';

sub register {
    my ($self, $app, $conf) = @_;

    $app->helper('psgi_session' => sub {
        my $c = shift;
        return $c->req->env->{'psgix.session'};
    });

    $app->helper('psgi_session_change_id'  => sub {
        my $c = shift;
        $c->req->env->{'psgix.session.options'}{'change_id'}++;
    });

    $app->helper('psgi_session_expire'  => sub {
        my $c = shift;
        $c->req->env->{'psgix.session.options'}{'expire'}++;
    });
}

1;
