package JavaScript::RPC::Server::CGI;

use strict;
use Carp;

our $VERSION = 0.03;

=head1 NAME

JavaScript::RPC::Server::CGI - Remote procedure calls from JavaScript

=head1 SYNOPSIS

	package MyJSRPC;
	
	use base qw( JavaScript::RPC::Server::CGI );
	
	sub add {
		my $self = shift;
	        unless( @_ == 2 and $_[ 0 ] =~ /^\d+$/ and $_[ 1 ] =~ /^\d+$/ ) {
        	        return $self->error( 'inputs must be \' digits only' )
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

=head1 DESCRIPTION

JavaScript::RPC::Server::CGI is a CGI-based server library for use with Brent
Ashley's JavaScript Remote Scripting (JSRS) client library. It works
asynchronously and uses DHTML to deal with the payload.

In order to add your custom meothds, this module should be subclassed.

The most current version (as of the release of this module) of the client
library as well as a demo application have been included in this
distribution.

=head1 METHODS

=head2 new()

Creates a new instance of the module. No further options are available at
this time.

=cut

sub new {
	my $class = shift;
	my $self  = {
		env => {}
	};

	bless $self, $class;

	return $self;
}

=head2 query()

Gets / sets the query object. It must be a CGI.pm compatible object.

=cut

sub query {
	my $self  = shift;
	my $query = shift || $self->{ query };

	unless( defined $query ) {
		require CGI;
		$query = CGI->new;
	}

	$self->{ query } = $query;

	return $query;
}

=head2 env()

Gets / sets a hash of information related to the currently query. The data
is empty until after process() has been executed. The resulting structure
contains four items:

=over 4 

=item * method - the method called

=item * params - an array of parameters for the method

=item * uid - the unique id for this query

=item * context - the context id

=back

=cut

sub env {
	my $self = shift;

	if( @_ and @_ % 2 == 0 ) {
		my %env  = @_;
		for( keys %env ) {
			$self->{ env }->{ $_ } = $env{ $_ };
		}
	}
	else {
		return $self->{ env }->{ $_[ 0 ] } if @_;
		return %{ $self->{ env } };
	}
}

=head2 error_message()

Get / sets the error message sent to the client if an error occurred.

=cut

sub error_message {
	my $self    = shift;
	my $message = shift;

	$self->{ error_message } = $message if $message;

	return $self->{ error_message };
}

=head2 process()

Processes the current query and either returns the result from the appropriate
method, or an error to the client and returns either true or false, respectively,
to the caller. An error will occur if the method name is blank, or the method
has not been defined. This function takes an optional CGI.pm compatible object
as an input.

Your subclass' methods should finish off with one of the following:

	# for an error...
	return $self->error( $message );

	# for a successful call...
	return $self->result( $result );

=cut

sub process {
	my $self   = shift;

	my $query  = shift || $self->query;

	my $method  = $query->param( 'F' ) || undef;
	my $uid     = $query->param( 'U' ) || undef;
	my $context = $query->param( 'C' ) || undef;

	my( $param, @params );
	my $i = 0;

	# Extract parameters
	while( defined( $param = $query->param( "P$i" ) ) ) {
		$param =~ s/^\[(.*)\]$/$1/;
		push @params, $param;
		$i++;
	}

	$self->env(
		method  => $method,
		uid     => $uid,
		context => $context,
		params  => \@params
	);

	print $query->header;

	return $self->error( 'No function specified' ) unless $method;
	return $self->error( 'Specified function not implemented' ) unless $self->can( $method );
	return $self->$method( @params );
}

=head2 error()

Returns a valid error payload to the client and false to the caller. It will
automatically call error_message() for you.

=cut

sub error {
	my $self    = shift;
	my $message = shift;
        my $msg_esc = _js_escape( $message );
	my %env     = $self->env;

	$self->error_message( $message );
	carp( $message );

	print <<"EO_ERROR";
<html>
<head></head>
<body onload="p = document.layers?parentlayer:window.parent; p.jsrsError( '$env{ context }', '$msg_esc' );">$message</body>
</html>
EO_ERROR

	return 0;
}

=head2 result()

Returns a valid result payload to the client and true to the caller.

=cut

sub result {
	my $self    = shift;
	my $message = shift;
	my %env     = $self->env;

	print <<"EO_RESULT";
<html>
<head></head>
<body onload="p = document.layers?parentLayer:window.parent; p.jsrsLoaded( '$env{ context }' );">jsrsPayload:<br />
<form name="jsrs_Form">
<textarea name="jsrs_Payload" id="jsrs_payload">$message</textarea>
</form>
</body>
</html>
EO_RESULT

	return 1;
}

=head1 SEE ALSO

=over 4 

=item * http://www.ashleyit.com/rs

=back

=head1 AUTHOR

=over 4 

=item * Brian Cassidy E<lt>brian@alternation.netE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;