package Kurious::Interface::DBI;

use Mojo::Base 'Kurious::Interface';
use Carp;

sub txn {
    my ($self, $code) = @_;

    state $dbi = $self->app->driver('DBI')->dbi;

    # do
    my $rows = $dbi->txn($code);

    # handle error
    if ( my $errstr = $dbi->dbh->errstr ) {
        $self->log->error($errstr);
        local $Carp::CarpLevel = 2;
        confess;
    }

    return $rows;
}

1;
