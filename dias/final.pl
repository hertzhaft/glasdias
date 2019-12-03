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

#my $places = do './places.pm';
#my $buildings = do './buildings.pm';

# files to rename (30.11.2019) = 5412 files (from clickjob and Google docs numbers_1-3.xsl);
my $rename = do './rename.pm';
my $renamed = c(@$rename);
say $renamed->size;
my $r_old = {};
my $r_new = {};
$renamed->each(sub {
  my ($new, $old) = @$_{'new','old'};
  $r_new->{$new} = $old;
  say $old if $r_old->{$old};
  $r_old->{$old} = $new;
  });
say scalar keys %$r_old;
say scalar keys %$r_new;
# my $repo = do './repo_all.pm';
# my $dias = do './dia_katalog.pm';

