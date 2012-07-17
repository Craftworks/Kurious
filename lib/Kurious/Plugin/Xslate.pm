package Kurious::Plugin::Xslate;

use Mojo::Base 'Mojolicious::Plugin';
use MojoX::Renderer::Xslate;
use HTML::FillInForm;

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
    };

    my $xslate = MojoX::Renderer::Xslate->build(
        'mojo' => $app, 'template_options' => $template_options,
    );

    $app->renderer->add_handler('tx' => $xslate);
}

1;
