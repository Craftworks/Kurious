package Kurious::Util;

use Mojo::Base -strict;
use Exporter::Lite;

our @EXPORT = qw(crlf2lf rows2kv rows2krows);

sub crlf2lf {
    local $_ = shift;
    s/\x0D\x0A/\n/go;
    tr/\x0D\x0A/\n\n/;
    return $_;
}

sub rows2kv {
    my ($rows, $key) = @_;

    unless ( ref $rows eq 'ARRAY' ) {
        Carp::croak('rows is not an ARRAY reference');
    }
    unless ( exists $rows->[0]{ $key } ) {
        Carp::croak(qq{key "$key" is not exists});
    }

    return +{ map { $_->{ $key } => $_ } @$rows };
}

sub rows2krows {
    my ($rows, $key) = @_;

    unless ( ref $rows eq 'ARRAY' ) {
        Carp::croak('rows is not an ARRAY reference');
    }
    unless ( exists $rows->[0]{ $key } ) {
        Carp::croak(qq{key "$key" is not exists});
    }

    my %krows;
    push @{ $krows{ $_->{ $key } } }, $_ for @$rows;

    return \%krows;
}

1;
