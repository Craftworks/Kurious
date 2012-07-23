package Kurious::Plugin::Pager;

use Mojo::Base 'Mojolicious::Plugin';
use POSIX ();

sub register {
    my ($self, $app, $conf) = @_;

    $app->helper('set_pager' => \&set_pager);
    $app->helper('set_navigation' => \&set_navigation);
}

sub set_pager {
    my ($self, $per_page) = @_;

    $self->app->log->error('####');
    $per_page = int $per_page || 10;

    my $page = $self->param('page');
    $page = 0 unless defined $page and length $page;
    my $current = int($page < 1 ? 1 : $page);

    $self->stash->{'pager'} = +{
        'current' => $current,
        'limit'   => $per_page,
        'offset'  => ($current - 1) * $per_page,
    };
}

sub set_navigation {
    my ($self, $numrows) = @_;

    my %p = %{ $self->stash->{'pager'} };
    $p{'numrows'} = $numrows || 0;

    $p{'numpages'} = POSIX::ceil($p{'numrows'} / $p{'limit'});
    $p{'first'}    = 1;
    $p{'last'}     = $p{'numpages'};
    $p{'prev'}     = $p{'current'} - 1;
    $p{'next'}     = $p{'current'} + 1;
    $p{'isfirst'}  = ($p{'current'} == $p{'first'});
    $p{'islast'}   = ($p{'current'} == $p{'last'});
    $p{'from'}     = $p{'prev'} * $p{'limit'} + 1;
    $p{'to'}       = ($p{'current'} == $p{'last'})
        ? $p{'numrows'} : $p{'current'} * $p{'limit'};

    # format link uri
    $p{'href'} = $self->req->url;
    $p{'href'} =~ s#https?://.+?/#/#o;
    $p{'href'} =~ s/&?page=[^&]*//go;
    $p{'href'} .= '?' if ( index($p{'href'}, '?') == -1 );
    my $start = $p{'current'} - 4;
    my $end   = $p{'current'} + 4;
    $end = ($end < 9) ? 9 : $end;
    if ( $p{'last'} < $end ) {
        $start = $p{'last'} - 8;
        $end   = $p{'last'};
    }
    $start = ($start <= 0) ? 1 : $start;

    my $amp = ($p{'href'} =~ /\?$/o) ? '' : '&';
    for my $i ( $start .. $end ) {
        push @{ $p{'pages'} }, +{
            'num'  => $i,
            'href' => $p{'href'} . $amp . 'page=' . $i,
        };
    }
    $p{'prevhref'}  = $p{'href'} . $amp . 'page=' . $p{'prev'};
    $p{'nexthref'}  = $p{'href'} . $amp . 'page=' . $p{'next'};
    $p{'firsthref'} = $p{'href'} . $amp . 'page=1';
    $p{'lasthref'}  = $p{'href'} . $amp . 'page=' . $p{'last'};

    $p{'prevhref'} = '' if $p{'isfist'};
    $p{'nexthref'} = '' if $p{'islast'};

    $self->stash->{'pager'} = \%p;
}

1;
