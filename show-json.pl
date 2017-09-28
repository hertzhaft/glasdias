#!/usr/bin/env perl
use utf8;

use Mojo::Base -strict;
use Mojo::Collection 'c';
use Mojo::File 'path';
use Mojo::IOLoop;
use Mojo::JSON qw(from_json decode_json);
use Mojo::UserAgent;
use Mojo::URL;
use Const::Fast;
use DDP { quote_keys => 1, align_hash => 0, hash_separator => ' => ', };

Mojo::File
  ->new('geo')
  ->list_tree()
  ->map( sub {
      @{decode_json($_->slurp)->{results}}
      })
  ->sort(sub { $a->{providedLocation}->{location} cmp $b->{providedLocation}->{location} })
  ->each( sub {
      say $_->{providedLocation}->{location};
        say '--', $_->{adminArea5}, ', ', $_->{adminArea4}, ', ', $_->{adminArea3},
          ' (', $_->{adminArea1}, '), geo: ',
          $_->{latLng}->{lat},',',$_->{latLng}->{lng}
          for @{$_->{locations}};
    });
