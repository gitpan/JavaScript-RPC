#!/usr/bin/perl

use strict;

use JavaScript::RPC::Server::CGI;

my $server = JavaScript::RPC::Server::CGI->new;

$server->method(
	add      => sub {
		return $_[ 0 ] + $_[ 1 ]
	},
	subtract => sub {
		return $_[ 0 ] - $_[ 1 ]
	}

);

$server->process;