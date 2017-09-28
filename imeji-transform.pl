#!/usr/bin/env perl
use utf8;

use Mojo::Base -strict;
use Mojo::Collection 'c';
use Mojo::File 'path';
use Mojo::IOLoop;
use Mojo::JSON 'from_json';
use Mojo::UserAgent;
use Mojo::URL;
use Const::Fast;
use DDP { quote_keys => 1, align_hash => 0, hash_separator => ' => ', };

# Single: http://open.mapquestapi.com/geocoding/v1/address?key=lAnw0OX1z1IHzw90qsyzbr0WQMb76YK0&location=Villeneuve-les-Avignon
# Batch (< 100) http://open.mapquestapi.com/geocoding/v1/batch?key=KEY&location=Denver,CO&location=Boulder,CO

const my $delta => 99;
const my $apikey => 'lAnw0OX1z1IHzw90qsyzbr0WQMb76YK0';
const my $imeji_query => '((bjPdsFEA_f4gqRo0:text="%s"))';
const my $url_geocode => "http://open.mapquestapi.com/geocoding/v1/address";
const my $url_batch => "http://open.mapquestapi.com/geocoding/v1/batch";
const my $url_imeji => "http://imeji-mediathek.de/imeji/collection/hFfmQSuYGYX2mJzI/browse";
const my $placemark => '
  <Placemark>
		<name>%s</name>
		<description>%s (%s) %s</description>
		<styleUrl>#gv_waypoint</styleUrl>
		<Point>
			<coordinates>%s,%s</coordinates>
		</Point>
	</Placemark>
';

my $items = from_json(path('items.json')->slurp);
my $results = $items->{results};
my $coll = bless $results, "Mojo::Collection";
my $hash = {};
$coll->each( sub {
	my $orig = $_->{metadata}->{'Subject: Place (Architecture)'};
	my $name = $orig;
	$name =~ s/\s*\(.+?\)\s*//g;
	$hash->{$name}->{orig} = $orig;
	$hash->{$name}->{count}++;
	});
my $keys = c(sort keys %$hash);
my $start = 0;
my $count = $keys->size;
my $ua = Mojo::UserAgent->new;
my $url = Mojo::URL->new($url_batch);
my $delay = Mojo::IOLoop->delay;
while ($start < $count) {
	my $end = $start+$delta > $count ? $count : $start+$delta;
	my $locs = $keys->slice($start .. $end-1)->map( sub {
	  $hash->{$_}->{orig}
	  })->to_array;
	my $url1 = $url->clone->query(key => $apikey, location => $locs);
	my $finish = $delay->begin;
    my $nr = $start;
    $ua->get($url1 => sub {
        my ($ua, $tx) = @_;
        my $res = $tx->res;
        say $res->message;
        my $json = $res->body;
        path("geo_$nr")->spurt($json);
        say "geo_json $nr received";
        $finish->();
    });
	$start += $delta;
	}

$delay->wait() unless $delay->ioloop->is_running();
say "complete";


#path('items.txt')->spurt(join("\n", sort keys %$hash));
#path('items.pl')->spurt(p $hash);
#my $frame = path('frame.kml')->slurp;

