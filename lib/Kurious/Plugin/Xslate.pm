package Kurious::Plugin::Xslate;

use Mojo::Base 'Mojolicious::Plugin';
use MojoX::Renderer::Xslate;
use HTML::FillInForm;
use Text::Xslate qw(html_builder mark_raw);

sub register {
    my ($self, $app, $conf) = @_;

    my $template_options = $app->config->{'template'} || {};

    $template_options->{'module'} = ['Text::Xslate::Bridge::Star'];

    my $fif = HTML::FillInForm->new;
    $template_options->{'function'} = +{
        'fillinform' => sub {
            my @vars = @_;
            return html_builder {
                my $raw  = shift; # Text::Xslate::Type::Row
                my $html = $raw->as_string;
                return $fif->fill(\$html, \@vars);
            };
        },
        'script' => sub {
            my $src = shift;
            return mark_raw(qq{<script src="$src"></script>});
        },
        'css' => sub {
            my $href = shift;
            return mark_raw(qq{<link rel="stylesheet" href="$href">});
        },
    };

    my $xslate = MojoX::Renderer::Xslate->build(
        'mojo' => $app, 'template_options' => $template_options,
    );

    $app->renderer->add_handler('tx' => $xslate);
}

1;
