#!/usr/bin/env perl
use utf8;

use Mojo::Base -strict;
use Mojo::Collection 'c';
use Mojo::File 'path';
use Mojo::IOLoop;
use Mojo::JSON 'from_json';
use Mojo::UserAgent;
use Mojo::URL;
use Mojo::Util 'url_escape';
use Const::Fast;
use DDP { quote_keys => 1, align_hash => 0, hash_separator => ' => ', };

# Single: http://open.mapquestapi.com/geocoding/v1/address?key=lAnw0OX1z1IHzw90qsyzbr0WQMb76YK0&location=Villeneuve-les-Avignon
# Batch (< 100) http://open.mapquestapi.com/geocoding/v1/batch?key=KEY&location=Denver,CO&location=Boulder,CO

const my $imeji_query => '((bjPdsFEA_f4gqRo0:text="%s"))';
const my $url_imeji => "http://imeji-mediathek.de/imeji/collection/hFfmQSuYGYX2mJzI/browse";

sub replace {
	my ($name, $desc) = @_;
	$desc = sprintf('<a href="%s&amp;q=%s">%s</a>', $url_imeji, url_escape(sprintf($imeji_query, $name)), $desc);
return qq|<name>$name</name>
			<description>$desc</description>|;
}

my $kml = path('Bing_all-places.kml')->slurp;
$kml =~ s/<name>(.*?)<\/name>\s+<description>(.*?)<\/description>/replace($1, $2)/eg;
path('all-places-with-links.kml')->spurt($kml);

