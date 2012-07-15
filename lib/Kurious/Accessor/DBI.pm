package Kurious::Accessor::DBI;

use Mojo::Base 'Kurious::Accessor';
use Carp;
use SQL::Abstract::Limit;
use SQL::Abstract::Plugin::InsertMulti;

has 'dbi' => sub { shift->driver('DBI')->dbi };
has 'sql' => sub {
    SQL::Abstract::Limit->new(
        'limit_dialect' => shift->config->{'limit_dialect'},
    );
};

sub run { shift->_do('run', @_) }
sub txn { shift->_do('txn', @_) }
sub _do {
    my ($self, $method, $code) = @_;

    my $dbi = $self->dbi;

    # do
    my $rows = $dbi->$method($code);

    # handle error
    if ( my $errstr = $dbi->dbh->errstr ) {
        $self->log->error($errstr);
        local $Carp::CarpLevel = 2;
        confess;
    }

    return $rows;
}

1;