#!/usr/bin/perl -w

package MyJSRPC;

use base qw( JavaScript::RPC::Server::CGI );

sub add {
	my $self = shift;
	unless( @_ == 2 and $_[ 0 ] =~ /^\d+$/ and $_[ 1 ] =~ /^\d+$/ ) {
		return $self->error( 'inputs must be digits only' ) 
	}
	return $self->result( $_[ 0 ] + $_[ 1 ] );
}

sub subtract {
	my $self = shift;
	unless( @_ == 2 and $_[ 0 ] =~ /^\d+$/ and $_[ 1 ] =~ /^\d+$/ ) {
		return $self->error( 'inputs must be digits only' ) 
	}
	return $self->result( $_[ 0 ] - $_[ 1 ] );
}

package main;

use strict;

my $server = MyJSRPC->new;
$server->process;