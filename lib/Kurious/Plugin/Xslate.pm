package Kurious::Plugin::Xslate;

use Kurious::Base 'Mojolicious::Plugin';
use MojoX::Renderer::Xslate;
use Text::Xslate qw(html_builder mark_raw);
use Class::Inspector;
use HTML::FillInForm;
use HTML::Packer;
use JavaScript::Minifier::XS 'minify';
use URI;
use URI::QueryParam;

sub register {
    my ($self, $app, $conf) = @_;

    my $template_options = $app->config->{'template'} || {};

    $template_options->{'module'} = ['Text::Xslate::Bridge::Star'];

    # define template functions
    for (@{ Class::Inspector->methods(ref $self, 'private') }) {
        next unless /^__function_(\w+)$/,
        $template_options->{'function'}{ $1 } = \&$_;
    }

    my $xslate = MojoX::Renderer::Xslate->build(
        'mojo' => $app, 'template_options' => $template_options,
    );

    $app->renderer->add_handler('tx' => $xslate);
}

sub __function_css {
    my $href = shift;
    return mark_raw(qq{<link rel="stylesheet" href="$href">});
}

sub __function_script {
    my $src = shift;
    return mark_raw(qq{<script src="$src"></script>});
}

sub __function_nl2br {
    my $str = shift;
    return unless defined $str and length $str;
    $str =~ s/\x0D\x0A/<br>/go;
    $str =~ s/[\x0D\x0A]/<br>/go;
    return mark_raw($str);
}

sub __function_fillinform {
    my @vars = @_;
    state $fif = HTML::FillInForm->new;
    return html_builder {
        my $raw  = shift; # Text::Xslate::Type::Raw
        my $html = $raw->as_string;
        return $fif->fill(\$html, \@vars);
    };
}

sub __function_query_param {
    my ($uri, $params, $deletes) = @_;
    my $u = URI->new($uri);
    $u->query_param_delete($_) for (@$deletes);
    $u->query_param(%$params);
    return $u;
}

sub __function_minify_html {
    state $packer = HTML::Packer->init;
    my $opts = shift;
    return html_builder {
        my $raw  = shift; # Text::Xslate::Type::Raw
        my $html = $raw->as_string;
        return $packer->minify(\$html, $opts);
    };
}

sub __function_minify_js {
    return html_builder {
        my $raw  = shift; # Text::Xslate::Type::Raw
        my $html = $raw->as_string;
        return minify($html);
    };
}

1;
