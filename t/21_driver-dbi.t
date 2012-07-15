use strict;
use warnings;
use Test::More;
use ok 'Kurious::Driver::DBI';
use MyApp;

$ENV{'USER'} = 'test1';

my $connect_info1 = [ 'dbi:mysql:', 'user1', '', undef ];
my $connect_info2 = [ 'dbi:mysql:', 'user2', '', undef ];

my $app = new_ok 'MyApp';
$app->config->{'Driver::DBI'} = +{
    'datasources' => {
        'test1' => $connect_info1,
        'test2' => $connect_info2,
    },
};

subtest 'object' => sub {
    my $driver = new_ok 'Kurious::Driver::DBI';
    isa_ok($driver, 'Kurious::Driver');
};

subtest 'connect_info' => sub {
    my $driver = $app->driver('DBI');
    can_ok($driver, 'connect_info');
    is_deeply($driver->connect_info, $connect_info1, 'detect');
    is_deeply($driver->connect_info('test2'), $connect_info2, 'specify');
}; 

subtest 'dbi' => sub {
    my $driver = $app->driver('DBI');
    isa_ok($driver->dbi, 'DBIx::Connector');
};

done_testing;
