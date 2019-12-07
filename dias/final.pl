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
<td><img data-src="%s"></td>
<td>%s</td>
<td><img data-src="%s"></td>
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
my $katfile = do './diakatalog.pm';
c(@$katfile)->each( sub { $kat->{$_->{name}} = $_; });


my $text = b(path('./diakatalog-repo-konkordanz.tab')->slurp)->split(qr{\R});
my $res = $text->sort->each( sub {
  my $count = $_[1];
  my ($dia, $nr) = (split /\s+/, $_);
  my $ref = $repo->{$dia}->{ref} // '';
  my $clk = "${clk}_${nr}_r.jpg";
  my $thumb = $ref ? "${ikb}${ref}" : '';
  push @$final, c($count, $nr, $clk, $dia, $thumb, $ref, map { $_ // '' } @{$kat->{$dia}}{qw(datecalc place building detail camera product)} );
  });
path('final.tab')->spurt($final->map(join => "\t")->join("\n"));
path('final.html')->spurt(
q#<html><head>
<style>
  img { width: 150px; min-height: 50px; }
  table, tr, td { border: 1px dotted gray; border-collapse: collapse; vertical-align: top; }
  td { padding: 0px 4px; }
</style>
<script>
// create config object: rootMargin and threshold are two properties exposed by the interface
const config = { rootMargin: '0px 0px 50px 0px', threshold: 0 };

var preloadImage = function (image) {
  image.src = image.dataset.src;
};

var onIntersection = function (entries) {
  entries.forEach(entry => {
    // Are we in viewport?
    if (entry.intersectionRatio > 0) {
      // Stop watching and load the image
      observer.unobserve(entry.target);
      preloadImage(entry.target);
    }
  });
};

const getCellValue = (tr, idx) => tr.children[idx].innerText || tr.children[idx].textContent;

const comparer = (idx, asc) => (a, b) => ((v1, v2) => 
    v1 !== '' && v2 !== '' && !isNaN(v1) && !isNaN(v2) ? v1 - v2 : v1.toString().localeCompare(v2)
    )(getCellValue(asc ? a : b, idx), getCellValue(asc ? b : a, idx));

// do the work...
var onLoad = function() {
  var images = document.querySelectorAll("img");
  images.forEach(image => { observer.observe(image); });
  document.querySelectorAll('th').forEach(th => th.addEventListener('click', (() => {
    const table = th.closest('table');
    Array.from(table.querySelectorAll('tr:nth-child(n+2)'))
        .sort(comparer(Array.from(th.parentNode.children).indexOf(th), this.asc = !this.asc))
        .forEach(tr => table.appendChild(tr) );
  })));
};

var observer = new IntersectionObserver(onIntersection, config);

window.onload = onLoad;
</script>
</head>
<table>
<tr>
<th>Nr</th>
<th>Box</th>
<th>Handwritten Number</th>
<th>Slide</th><th>Preview</th>
<th>Repo ref nr</th>
<th>date</th>
<th>place</th>
<th>building</th>
<th>detail</th>
<th>camera</th>
<th>product</th>
</tr>
#,
$final->map(sub { sprintf($html, @$_); })->join(),
'</table></html>'
);



