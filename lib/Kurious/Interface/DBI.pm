package Kurious::Interface::DBI;

use Kurious::Base 'Kurious::Interface';
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

sub numrows {
    my ($self, $stuff) = @_;

    state $rows;

    return $rows unless defined $stuff;

    if ( $stuff =~ /^\d+$/o ) {
        $rows = $stuff;
    }
    elsif ( $stuff->isa('Kurious::Accessor') ) {
        $rows = $stuff->found_rows;
    }
    else {
        Carp::croak(qq{$stuff isn't a 'Kurious::Accessor'});
    }

    return $rows;
}

1;
