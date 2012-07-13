package Kurious::Log;

use Mojo::Base 'Mojo::Log';
use Data::Dumper;

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

our %Color = (
    'query' => 'magenta',
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

sub is_level {
    my ($self, $level) = @_;
    $Level->{ lc $level } >= $Level->{ $ENV{'MOJO_LOG_LEVEL'} || $self->level };
}

sub dump {
    my $self = shift;
    local $Data::Dumper::Terse
        = $Data::Dumper::Indent
        = $Data::Dumper::SortKeys = 1;
    my $message = Dumper \@_; chomp $message;
    $self->debugf("$message at %s line %d", (caller)[0, 2]);
}

sub log {
    my $self  = shift;
    my $level = lc shift;
    my @messages = @_;

    if ( $self->is_color ) {
        my $color = $Color{ $level };
        if ( defined $color && length $color ) {
            map { $_ = Term::ANSIColor::colored($_, $color) } @messages;
        }
    }

    $self->SUPER::log($level, @messages);
}

sub query  { shift->log('query' => @_) }
sub debugf { shift->log('debug' => sprintf shift, @_) }
sub infof  { shift->log('info'  => sprintf shift, @_) }
sub warnf  { shift->log('warn'  => sprintf shift, @_) }
sub errorf { shift->log('error' => sprintf shift, @_) }
sub fatalf { shift->log('fatal' => sprintf shift, @_) }

sub is_query { shift->is_level('query') }

1;
