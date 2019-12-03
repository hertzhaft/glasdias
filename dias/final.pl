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
# my $rename = do './rename.pm';

my $final = c;
my $ikb = 'https://rs.cms.hu-berlin.de/ikb_mediathek/pages/download.php?size=thm&ref=';
my $clk = 'http://www.kunstgeschichte.hu-berlin.de/clickjob/SCHG';
my $html = q|
<tr>
<td>%s</td>
<td>%s</td>
<td><img src="%s"></td>
<td>%s</td>
<td><img src="%s"></td>
<td>%s</td>
<td>%s</td>
<td>%s</td>
<td>%s</td>
<td>%s</td>
<td>%s</td>
<td>%s</td>
</tr>
|;

my $repo = {};
my $repofile = do './repo_all.pm';
c(@$repofile)->each( sub { $repo->{$_->{name}} = $_; });

my $kat = {};
my $katfile = do './dias.pm';
c(@$katfile)->each( sub { $kat->{$_->{name}} = $_; });


my $text = b(path('./all_dias1.tab')->slurp)->split(qr{\R});
my $res = $text->sort->each( sub {
  my $count = $_[1];
  my ($dia, $nr) = (split /\s+/, $_);
  my $ref = $repo->{$dia}->{ref} // '';
  my $clk = "${clk}_${nr}_r.jpg";
  my $thumb = $ref ? "${ikb}${ref}" : '';
  push @$final, c($count, $nr, $clk, $dia, $thumb, $ref, map { $_ // '' } @{$kat->{$dia}}{qw(datecalc place building detail camera product)} );
  });
b($final->map(join => "\t")->join("\n"))->say;
#say '<html><head>
#<style>
#  img { width: 150px; }
#  table, tr, td { border: 1px dotted gray; border-collapse: collapse; vertical-align: top; }
#</style>
#</head>
#<table>';
#
#b($final->map(sub { sprintf($html, @$_); })->join())->say;
#
#say '</table></html>';



