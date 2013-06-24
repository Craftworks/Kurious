package Kurious::Log;

use Kurious::Base 'Mojo::Log';
use Carp;
use POSIX 'strftime';
use Data::Dumper;

our %Color = (
    'query' => 'magenta',
    'dump'  => 'bold cyan',
    'debug' => 'cyan',
    'info'  => '',
    'warn'  => 'yellow',
    'error' => 'red',
    'fatal' => 'bold red',
);

our $Level = {
    'query' => 1,
    'debug' => 1,
    'info'  => 2,
    'warn'  => 3,
    'error' => 4,
    'fatal' => 5,
};

has 'is_tty' => sub {
    return -t shift->handle;
};

has 'has_ansi_color' => sub {
    return eval { require Term::ANSIColor };
};

has 'is_color' => sub {
    my $self = shift;
    return $self->is_tty && $self->has_ansi_color;
};

has 'escseq' => sub {
    +{ map { $_ => Term::ANSIColor::color($_) } values(%Color), 'reset' };
};

sub is_level {
    my ($self, $level) = @_;
    $Level->{ lc $level } >= $Level->{ $ENV{'MOJO_LOG_LEVEL'} || $self->level };
}

sub dump {
    my $self = shift;
    state $color = $self->is_color ? $self->escseq->{ $Color{'dump'} } : '';
    state $reset = $self->is_color ? $self->escseq->{ 'reset' } : '';

    local $Data::Dumper::Terse
        = $Data::Dumper::Indent
        = $Data::Dumper::SortKeys = 1;

    my @caller;
    unless ( caller 1 ) {
        @caller = caller;
    }
    else {
        @caller = substr((caller 1)[3], -3) eq '::d' ? (caller 2) : (caller 1);
    }

    my $message = Dumper \@_; chomp $message;
    if ( $self->is_color ) {
        $message = $color . $message . $reset;
    }
    $message .= sprintf ' at %s line %d', @caller[0, 2];

    $self->debug($message);
}

sub fatal {
    my $message = shift->log(fatal => @_);
    local $Carp::CarpLevel += 1;
    confess $message;
}

sub log {
    my $self  = shift;
    my $level = lc shift;
    my @messages = @_;

    if ( $self->is_color ) {
        state $escseq = $self->escseq;
        state $reset  = $escseq->{'reset'};
        my $color = $Color{ $level };
        if ( defined $color && length $color ) {
            map { $_ = defined $_
                    ? $escseq->{ $color } . $_ . $reset : '' } @messages;
        }
    }

    $self->SUPER::log($level, @messages);

    return "@messages";
}

sub format {
    my ($self, $level, @msgs) = @_;
    return strftime('[%Y-%m-%d %T]', localtime) . " [$level] @msgs\n";
}

sub query  { shift->log('query' => @_) }
sub debugf { shift->logf('debug' => shift, @_) }
sub infof  { shift->logf('info'  => shift, @_) }
sub warnf  { shift->logf('warn'  => shift, @_) }
sub errorf { shift->logf('error' => shift, @_) }
sub fatalf {
    my $message = shift->logf('fatal' => shift, @_);
    local $Carp::CarpLevel += 1;
    confess $message;
}

sub logf {
    my ($self, $level, $format, @messages) = @_;
    local $SIG{__WARN__} = local $SIG{__DIE__} = *Carp::confess;
    local $Carp::CarpLevel = $Carp::CarpLevel + 2;
    $self->log($level => sprintf $format, @messages);
}

sub is_query { shift->is_level('query') }

1;
