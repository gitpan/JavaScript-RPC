package JavaScript::RPC::Server::CGI;

use strict;
use Carp;

our $VERSION = 0.01;

=head1 NAME

JavaScript::RPC::Server::CGI - Remote procedure calls from JavaScript

=head1 SYNOPSIS

	use JavaScript::RPC::Server::CGI;

	my $server = JavaScript::RPC::Server::CGI->new;

	# define "add" and "subtract" methods
	$server->method(
		add      => sub {
			return $_[ 0 ] + $_[ 1 ];
		},
		subtract => sub {
			return $_[ 0 ] - $_[ 1 ];
		}
	);

	# process the query
	$server->process;

=head1 DESCRIPTION

JavaScript::RPC::Server::CGI is a CGI-based server library for use with Brent
Ashley's JavaScript Remote Scripting (JSRS) client library. It works
asynchronously and uses DHTML to deal with the payload.

The most current version (as of the release of this module) of the client
library as well as an demo application have been included in this
distribution.

=head1 METHODS

=head2 new()

Creates a new instance of the module. No further options are available at
this time.

=cut

sub new {
	my $class = shift;
	my $self  = {
		methods => {},
		info    => {}
	};

	bless $self, $class;

	return $self;
}

=head2 method()

Define and retrieve the server's methods. To define a method, supply
a key-value pair of the method's name a reference to the subroutine
to execute. You can get back any method by supplying its name.

=cut

sub method {
	my $self    = shift;

	if( @_ > 1 ) {
		my %methods = @_;
		for( keys %methods ) {
			$self->{ methods }->{ $_ } = $methods{ $_ };
		}
	}
	else {
		return $self->{ methods }->{ $_[ 0 ] };
	}
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

=head2 info()

Gets / sets a hash of information related to the currently query. The data
is empty until after process() has been executed. The resulting structure
contains four items:

=over 4 

=item * the method called

=item * an array of parameters for the method

=item * the unique id for this query

=item * the context id

=back

=cut

sub info {
	my $self = shift;
	my %info = @_;

	$self->{ info } = \%info if %info;

	return %{ $self->{ info } };
}

=head2 process()

Processes the current query and either returns the result from the appropriate
method, or an error to the client and return either true or false, respectively,
to the caller. An error will occur if the method name is blank, or the method
has not been defined. This function takes an optional CGI.pm compatible object
as an input.

NOTE: Things seem to break with IIS && Firebird (at least) if the content-type
header is not printed before we create a new CGI object. This means supplying
a query object to this function, or using the query() method BEFORE process()
can break things.

=cut

sub process {
	my $self   = shift;

	# Print the content-type before we deal with a query object
	print "Content-type: text/html\n\n";

	my $query  = shift || $self->query;

	my $method  = $query->param( 'F' );
	my $uid     = $query->param( 'U' );
	my $context = $query->param( 'C' );

	my( $param, @params );
	my $i = 0;

	# Extract parameters
	while( defined( $param = $query->param( "P$i" ) ) ) {
		$param =~ s/^\[(.*)\]$/$1/;
		push @params, $param;
		$i++;
	}

	$self->info(
		method  => $method,
		uid     => $uid,
		context => $context,
		params  => \@params
	);

#	print $query->header;

	return $self->error( 'No function specified' ) if $method eq '';
	return $self->error( 'Specified function not implemented' ) unless $self->method( $method );
	return $self->result( $self->method( $method )->( @params ) );
}

=head2 error()

Returns a valid error payload to the client and false to the caller.

=cut

sub error {
	my $self    = shift;
	my $message = shift;
	my %info    = $self->info;

	carp( $message );

	print <<"EO_ERROR";
<html>
<head></head>
<body onload="p = document.layers?parentlayer:window.parent; p.jsrsError( '$info{ context }', '$message' );">$message</body>
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
	my %info    = $self->info;

	print <<"EO_RESULT";
<html>
<head></head>
<body onload="p = document.layers?parentLayer:window.parent; p.jsrsLoaded( '$info{ context }' );">jsrsPayload:<br />
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