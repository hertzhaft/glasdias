#!/usr/bin/env perl
use utf8;

use Mojo::Base -strict;
use Mojo::Collection 'c';
use Mojo::File 'path';
use Mojo::JSON 'from_json';
use Mojo::UserAgent;
use Mojo::URL;
use DDP { quote_keys => 1, align_hash => 0, hash_separator => ' => ', };

my $apikey = 'lAnw0OX1z1IHzw90qsyzbr0WQMb76YK0';
my $url_geocode = "http://open.mapquestapi.com/geocoding/v1/address";
my $placemark = qq|
  <Placemark>
		<name>%s</name>
		<description>%s (%s) %s</description>
		<styleUrl>#gv_waypoint</styleUrl>
		<Point>
			<coordinates>%s,%s</coordinates>
		</Point>
	</Placemark>
|;

# Single: http://open.mapquestapi.com/geocoding/v1/address?key=lAnw0OX1z1IHzw90qsyzbr0WQMb76YK0&location=Villeneuve-les-Avignon

# Batch (< 100) http://open.mapquestapi.com/geocoding/v1/batch?key=KEY&location=Denver,CO&location=Boulder,CO
my $data = from_json(path('items.json')->slurp);
my $results = $data->{results};
my $coll = bless $results, "Mojo::Collection";
my $url = Mojo::URL->new($url_geocode);
my $hash = {};
for my $item (@$results) {
	my $name = $item->{metadata}->{'Subject: Place (Architecture)'};
	$name =~ s/\s*\(.+?\)\s*//g;
	$hash->{$name}->{count}++;
	}
path('items.txt')->spurt(join("\n", sort keys %$hash));
path('items.pl')->spurt(p $hash);
my $frame = path('frame.kml')->slurp;

