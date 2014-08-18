package Kurious::Plugin::Xslate;

use Kurious::Base 'Mojolicious::Plugin';
use MojoX::Renderer::Xslate;
use Text::Xslate qw(html_builder mark_raw unmark_raw html_escape);
use Class::Inspector;
use POSIX 'strftime';
use Scalar::Util 'blessed';
use HTML::FillInForm;
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
    my $html = qq{<script src="$src"};
    $html .= ' ' . join ' ', @_ if @_;
    $html .= q{></script>};
    return mark_raw($html);
}

sub __function_nl2br {
    my $str = shift;
    return unless defined $str and length $str;
    $str =~ s/\x0D\x0A/<br>/go;
    $str =~ s/[\x0D\x0A]/<br>/go;
    return mark_raw($str);
}

sub __function_commify {
    local $_ = shift;
    return unless defined and length;
    1 while s/^([-+]?\d+)(\d\d\d)/$1,$2/o;
    $_;
}

sub __function_fillinform {
    my @vars = @_;
    my $fif = HTML::FillInForm->new;
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

sub __function_strftime {
    my ($format, $time, $tz) = @_;

    $time ||= time;
    $tz   ||= 'UTC';

    local $ENV{'TZ'} = $tz;
    return strftime($format, localtime $time);
}

sub __function_json {
    my $vars = shift;

    require Data::Rmap;
    require JSON::XS;
    state $json = JSON::XS->new->ascii;

    Data::Rmap::rmap_to(sub {
        Data::Rmap::cut($_) if blessed($_);
        return if ref;
        $_ = unmark_raw(html_escape($_));
    }, Data::Rmap::ALL(), $vars);

    my $str = $json->encode($vars);
    my $bs = '\\';
    $str =~ s!/!${bs}/!g;
    $str =~ s!<!${bs}u003c!g;
    $str =~ s!>!${bs}u003e!g;
    $str =~ s!&!${bs}u0026!g;
    Text::Xslate::mark_raw($str);
}

sub __function_minify_html {
    require HTML::Packer;
    HTML::Packer->import;
    state $packer = HTML::Packer->init;
    my $opts = shift;
    return html_builder {
        my $raw  = shift; # Text::Xslate::Type::Raw
        my $html = $raw->as_string;
        return $packer->minify(\$html, $opts);
    };
}

sub __function_minify_js {
    require JavaScript::Minifier::XS;
    return html_builder {
        my $raw  = shift; # Text::Xslate::Type::Raw
        my $html = $raw->as_string;
        return JavaScript::Minifier::XS::minify($html);
    };
}

sub __function_youtube_embed_url {
    my $url = shift;

    if ( $url =~ m{(?:youtu.be/|youtube.com/(?:watch\?(?:.*&)?v=|(?:embed|v)/))([^?&"'>]+)}o ) {
        $url = $1;
        return "//www.youtube.com/embed/$1";
    }
    else {
        return '';
    }
}

sub __function_slideshare_embed_url {
    my $url = shift;

    if ( $url =~ m{(//www\.slideshare\.net/slideshow/embed_code/\d+)}o ) {
        return $1;
    }
    else {
        return '';
    }
}

sub __function_itunes_id {
    my $url = shift;

    if ( $url =~ m{id(\d+)}o ) {
        return $1;
    }
    else {
        return '';
    }
}

my @stash;
sub __function_stash_push {
    return html_builder {
        push @stash, shift->as_string;
        return;
    };
}
sub __function_stash_pop {
    return mark_raw(pop @stash);
}
sub __function_stash_slurp {
    return mark_raw(join '', splice @stash, 0, @stash);
}

1;
