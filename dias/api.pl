#!/usr/bin/perl -w
use Mojo::Base '-strict';
use Mojo::ByteStream 'b';
use Mojo::Collection 'c';
use Mojo::File 'path';
use Mojo::UserAgent;

use IO::Socket::SSL;
use DDP;
use Digest::SHA qw(sha256_hex);
use JSON;
use URL::Encode 'url_encode';

# Set the private API key for the user (from the user account page) and the user we're accessing the system as.
# my $user = "admin";
# my $private_key = "d2b02376386580778603a6ead6453f74aefe3b9861eb89a91a63a4569c15cc14";

my $host = 'https://rs.cms.hu-berlin.de';
my $path = 'ikb_mediathek/api';
my $user = "imagelab";
my $pass = "arDia*2019";
my $private_key = "e92f87d9191e4c8509216d8ca918b679c60ece35ff8a6369e0df0eb2f2142d33";

# my $headers = {'Content-Type' => 'multipart/form-data'};
# my $function = 'get_user_collections';

sub apiCall {
	my $function= shift;
	my $count = 1;
	my @params = map { 'param' . $count++ => $_ } @_;
	my $ua = Mojo::UserAgent->new;
	my $tx = $ua->build_tx(GET => $host);
	my $url = $tx->req->url
	->path($path . '/')
	->query(user => $user, function => $function, @params);
	say $url->query;
	my $sign = sha256_hex($private_key . $url->query);
	# Sign the query using the private key
	$url->query([sign => $sign]);
	my $res = $ua->start($tx)->res;
	return $res->body;
}

sub getFieldOptions {
	my $field = shift;
	return apiCall('get_field_options' => $field, 'TRUE');
}

sub getPlacesListApi {
	# objektort - 87
	return getFieldOptions(87);
}
	
sub getBuildingsListApi {
	# objektbezeichnung - 86
	return getFieldOptions(86);
}

sub readPlacesList {
	my $coll = do './places.pm';
	return c(@$coll);
}
	
sub readBuildingsList {
	my $coll = do './buildings.pm';
	return c(@$coll);
}

sub readDiaList {
	my $coll = do './dias.pm';
	return c(@$coll);
}

sub getDiaCollection {
	my $json = apiCall('do_search' => '!collection6129');
	return c(@$json)
		->grep( sub {
			$_->{field8} =~ /^SCHG_/;
			})
		->map( sub {
			+{ $_->{field8} => $_->{ref} }
			});
	}

sub getResource {
	my $ref = shift;
	apiCall('get_resource_data' => $ref);
}

sub getNodeID {
	my ($str, $fieldID) = @_;
	apiCall('get_node_id' => $str, $fieldID);
}

# my $json = apiCall('get_user_collections');
# my $json = apiCall('search_public_collections');
# my $json = apiCall('do_search', '!collection6129;field8:SCHG_*');
# my $json = apiCall('do_search', '!collection6129');
# collection!6129
# originalfilename - 51

# my $json = apiCall('update_field' => 43283, 87, q{Siena (Italien, Toskana) (Q2751)}), 0;

# my $json = getNodeID(q{Siena}, '87');
my $json = getFieldOptions(87);

p($json);
