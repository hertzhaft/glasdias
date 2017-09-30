#!/usr/bin/env perl
use utf8;

use Mojo::Base -strict;
use Mojo::Collection 'c';
use Mojo::DOM;
use Mojo::File 'path';
use Mojo::IOLoop;
use Mojo::JSON qw(from_json decode_json);
use Mojo::UserAgent;
use Mojo::URL;
use Const::Fast;
use DDP { quote_keys => 1, align_hash => 0, hash_separator => ' => ', };

my $kml = Mojo::File
  ->new('all-places-with-links.kml')
  ->slurp;
my $dom = Mojo::DOM->new($kml);
my $pm = $dom->find('a')->each(sub {
	my $href = $_->attr('href');
	$href =~ s/&/?/g;
	$_->attr(href => $href);
	});

say substr($dom->to_string, 0,200);