#! /usr/bin/env perl
use Mojolicious::Lite;

use Mojo::Base '-strict';
use Mojo::ByteStream 'b';
use Mojo::Collection 'c';
use Mojo::File 'path';
use Mojo::Loader 'data_section';
use Mojo::SQLite;
use Mojo::URL;
use DDP;

# make standard output (say, print) use UTF-8
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

*_f = \&CORE::sprintf;

my $orig= "Aksum (Äthiopien) (Q5832) (GC 14.1213, 38.7285)";
my $orig1= "Aksum (Äthiopien) (Q5832)";
my $orig2 = "Youngstown (USA, Ohio) (Q216820) (GC 41.09639, -80.64917)";

my $out = qq|<Placemark>
<name>%s</name>
<description>
<![CDATA[
<a href="https://rs.cms.hu-berlin.de/ikb_mediathek/pages/search.php?search=%s">Link</a>]]></description>
<link>
<a href="https://rs.cms.hu-berlin.de/ikb_mediathek/pages/search.php?search=%s">Link</a>
</link>
<styleUrl>#gv_waypoint</styleUrl>
<Point><coordinates>GC %s, %s</coordinates></Point></Placemark>
|;
no warnings 'uninitialized';

my ($place, $q, $lon, $lat);

my $RE_PLACES = qr|^(.+)\s+\((Q\d\d+)\)(?:\s+\(GC\s+([\d\.\-]+), ([\d\.\-]+)\)\s*)?$|;

($place, $q, $lon, $lat) = $orig =~ $RE_PLACES;
say "|$place|$q|$lon|$lat|";
($place, $q, $lon, $lat) = $orig1 =~ $RE_PLACES;
say "|$place|$q|$lon|$lat|";
($place, $q, $lon, $lat) = $orig2 =~ $RE_PLACES;
say "|$place|$q|$lon|$lat|";
