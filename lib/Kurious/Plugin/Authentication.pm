package Kurious::Plugin::Authentication;

use Kurious::Base 'Mojolicious::Plugin';

sub register {
    my ($self, $app, $conf) = @_;

    $app->helper('set_authenticated' => sub {
        my ($c, $user) = @_;
        $c->psgi_session->{'user'} = $user;
    });

    $app->helper('user' => sub {
        my $c = shift;
        $c->psgi_session->{'user'};
    });

    $app->helper('user_exists' => sub {
        my $c = shift;
        $c->user ? 1 : 0;
    });

    $app->helper('user_id' => sub {
        my $c = shift;
        $c->user ? $c->user->{'user_id'} : undef;
    });

    $app->helper('user_has_role' => sub {
        my ($c, $role) = @_;
        $c->user->{'role'} eq $role;
    });

    $app->helper('logout' => sub {
        my ($c, $redirect_to) = @_;
        $redirect_to ||= '/';
        $c->psgi_session_expire;
        $c->redirect_to($redirect_to);
    });
}

1;
