package Kurious::Controller;
use Kurious::Base 'Mojolicious::Controller';
sub log { shift->app->log }
sub d   { shift->app->log->dump(@_) }

sub action_path {
    my $self = shift;

    my $caller = (caller 4)[3];
    my $app_class = $self->app->home->app_class;
    my $action = substr $caller, length("$app_class\::Controller::");
    $action =~ s{::}{/}go;

    return lc $action;
}

sub template_dir {
    return '.';
}

sub template_renderer {
    my ($self, $template) = @_;

    return sub {
        my %opts;

        $template ||= $self->stash->{'template'} || $self->action_path;

        $opts{'format'}   = $self->stash('format') || 'html';
        $opts{'handler'}  = $self->stash('handler') || 'tx';

        my $template_dir = $self->template_dir;
        my $filename     = join '.', $template, @opts{qw/format handler/};

        $opts{'template'} = File::Spec->catfile($template_dir, 'layout');
        $opts{'content'}  = File::Spec->catfile($template_dir, $filename);

        $opts{'env'}  = \%ENV;

        $self->log->debugf('Render template "%s" with "%s"', @opts{qw/template content/});
        $self->render(%opts);
    };
}

sub json_renderer {
    my $self = shift;

    my @caller = (caller 1)[0,2];
    my $message = "render_json() requires variable \$self->stash('json')"
                . " at %s line %d";

    return sub {
        my $json = $self->stash('json');
        $self->log->warnf($message, @caller) unless defined $json;
        $self->render_json($json);
    }
}

1;
