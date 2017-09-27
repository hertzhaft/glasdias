#!/usr/bin/env perl
use utf8;

use Mojo::Base -strict;
use Mojo::File 'path';
use Mojo::JSON 'from_json';
use DDP { quote_keys => 1, align_hash => 0, hash_separator => ' => ', };

my $data = from_json(path('items.json')->slurp);
my $results = $data->{results};
my $hash = {};
for my $item (@$results) {
	my $name = $item->{metadata}->{'Subject: Place (Architecture)'};
	$name =~ s/\s*\(.+?\)\s*//g;
	$hash->{$name}->{count}++;
	}
path('items.txt')->spurt(join("\n", sort keys %$hash));
path('items.pl')->spurt(p $hash);

