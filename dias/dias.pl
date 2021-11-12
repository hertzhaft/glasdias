#!/usr/bin/perl -w
use Mojo::Base '-strict';
use Mojo::ByteStream 'b';
use Mojo::Collection 'c';
use Mojo::File 'path';
use Mojo::UserAgent;
use Mojo::Util;

use DDP;
use Digest::SHA qw(sha256_hex);
use JSON;

# WIKIDATA
# https://www.wikidata.org/w/api.php?action=wbsearchentities&search=zadar&format=json&language=en&uselang=en&type=item

my $dias = do './dias.pm';
my $places = do './places.pm';
my $buildings = do './buildings.pm';
# my $dias_db = do './dias_db.pm';

my c

