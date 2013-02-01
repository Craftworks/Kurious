package Kurious::Plugin::Xslate;

use Kurious::Base 'Mojolicious::Plugin';
use MojoX::Renderer::Xslate;
use Text::Xslate qw(html_builder mark_raw);
use HTML::FillInForm;
use HTML::Packer;
use URI;
use URI::QueryParam;

sub register {
    my ($self, $app, $conf) = @_;

    my $template_options = $app->config->{'template'} || {};

    $template_options->{'module'} = ['Text::Xslate::Bridge::Star'];

    my $fif = HTML::FillInForm->new;
    $template_options->{'function'} = +{
        'css' => sub {
            my $href = shift;
            return mark_raw(qq{<link rel="stylesheet" href="$href">});
        },
        'script' => sub {
            my $src = shift;
            return mark_raw(qq{<script src="$src"></script>});
        },
        'nl2br' => sub {
            my $str = shift;
            $str =~ s/\x0D\x0A/<br>/go;
            $str =~ s/[\x0D\x0A]/<br>/go;
            return mark_raw($str);
        },
        'fillinform' => sub {
            my @vars = @_;
            return html_builder {
                my $raw  = shift; # Text::Xslate::Type::Raw
                my $html = $raw->as_string;
                return $fif->fill(\$html, \@vars);
            };
        },
        'query_param' => sub {
            my ($uri, %params) = @_;
            my $u = URI->new($uri);
            $u->query_param(%params);
            return $u;
        },
        'minify' => sub {
            state $packer = HTML::Packer->init;
            my $opts = shift;
            return html_builder {
                my $raw  = shift; # Text::Xslate::Type::Raw
                my $html = $raw->as_string;
                return $packer->minify(\$html, $opts);
            };
        },
    };

    my $xslate = MojoX::Renderer::Xslate->build(
        'mojo' => $app, 'template_options' => $template_options,
    );

    $app->renderer->add_handler('tx' => $xslate);
}

1;
