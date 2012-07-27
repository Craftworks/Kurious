package Kurious::Driver::DBI;

use Mojo::Base 'Kurious::Driver';
use DBIx::Connector;

has 'dbi' => sub {
    my $self = shift;

    my $connect_info = $self->connect_info;
    my $dbi = DBIx::Connector->new(@$connect_info);
    $dbi->mode('fixup');

    # Modify default values.
    # the error is handled automatic by Kurious::Accessor::DBI->_do()
    $dbi->dbh->STORE('RaiseError' => 0)
        unless exists $connect_info->[3]{'RaiseError'};
    $dbi->dbh->STORE('PrintError' => 0)
        unless exists $connect_info->[3]{'PrintError'};

    return $dbi;
};

sub new {
    my $self = shift->SUPER::new(@_);

    my $config = $self->config->{'Driver::DBI'};
    unless ( defined $config ) {
        die sprintf "config->{'Driver::DBI'} must be defined for %s.",
            ref $self;
    }

    my $logger = sub {
        my %params = @_;
        $params{'qps'}  = 1 / $params{'time'};
        $params{'msec'} = $params{'time'} * 1000;

        my $message = sprintf "(%.3fmsec/%dqps) %s; at %s line %d",
                    @params{qw(msec qps sql pkg line)};
        $message =~ tr/\x0D\x0A//d;

        $self->log->can('query')
            ? $self->log->query($message)
            : $self->log->debug($message);
    };

    unless ( $ENV{'HARNESS_ACTIVE'} and !$ENV{'MOJO_LOGGING'} ) {
        require DBIx::QueryLog;
        DBIx::QueryLog->import;
        $DBIx::QueryLog::OUTPUT = $logger;
    }

    return $self;
}

sub connect_info {
    my ($self, $datasource_key) = @_;

    my $config = $self->config->{'Driver::DBI'};

    if ( my $connect_info = $config->{'datasource'} ) {
        return $connect_info;
    }

    $datasource_key ||= $ENV{'USER'} || $config->{'datasource_key'};
    $datasource_key ||= (getpwuid $>)[0];
    $self->log->info(qq{datasource key is "$datasource_key"});

    my $connect_info = $config->{'datasources'}{ $datasource_key };
    unless ( defined $connect_info ) {
        die sprintf qq{datasource "%s" is not defined in config.},
        $datasource_key;
    }

    unless ( ref $connect_info eq 'ARRAY'
        && defined $connect_info->[0] && $connect_info->[0] =~ /^dbi:/io ) {
        no warnings 'once';
        local $Data::Dumper::Terse = 1;
        die "invalid connect_info.\n" . Dumper($connect_info);
    }

    return $connect_info;
}

1;
