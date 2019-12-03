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

my $h = {};
my $text = b(path('./all_dias.tab')->slurp)->split(qr{\R});
my $res = $text->each( sub {
  my ($dia, $nr) = (split /\t/, $_);
  say $dia if $h->{$dia};
  $h->{$dia}++
  });

#my $text = b(path('./Numbers_all_by_dia.tab')->slurp)->split(qr{\R});
#my $res = $text->sort->join("\n");
#path('./all_dias.tab')->spurt($res);

#my $text = b(path('./Numbers1.json')->slurp)->split(qr{\R});
#
#my $res = $text->map( sub {
#  return unless $_;
#  my ($nr, $dia) = ($_ =~ /SCHG_([\d\.]+).*?"([09]\d\d\d\d\d)"/);
#  return unless $dia;
#  $dia = $dia =~ /^0/ ? "20$dia" : "19$dia";
#  return "$dia\t$nr";
#  
#  })
#  ->sort
#  ->join("\n");
#path('./00.tab')->spurt($res);

#my ()$text =~ s/SCHG_//g;
#say length $text;
#$text =~ s/_r//g;
#say length $text;
#path('./dia_katalog.pm')->spurt($text);