package Kurious::Accessor::DBI;

use Kurious::Base 'Kurious::Accessor';
use Carp;
use SQL::Abstract::Limit;
use SQL::Abstract::Plugin::InsertMulti;

has 'dbi' => sub { shift->driver('DBI')->dbi };
has 'sql' => sub {
    my $config = shift->config->{'Accessor::DBI'};
    SQL::Abstract::Limit->new(
        'limit_dialect' => $config->{'limit_dialect'} || 'LimitXY',
    );
};

has 'found_rows';

sub run { shift->_do('run', @_) }
sub txn { shift->_do('txn', @_) }
sub _do {
    my ($self, $method, $code) = @_;

    my $dbi = $self->dbi;

    # do
    my $rows = $dbi->$method($code);

    # handle error
    if ( my $errstr = $dbi->dbh->errstr ) {
        local $Carp::CarpLevel = 2;
        confess $self->log->error($errstr);
    }

    return $rows;
}

sub set_found_rows {
    my $self = shift;

    my ($rows) = $self->dbi->dbh->selectrow_array('SELECT FOUND_ROWS()');
    $self->found_rows($rows);
}

1;
