package MyJSRPC;

use base qw( JavaScript::RPC::Server::CGI );

sub add {
	my $self = shift;
	if( @_ == 2 ) {
		return $_[ 0 ] + $_[ 1 ];
	}
	else {
		die '2 numbers are needed';
	}
}

package main;

use Test::More tests => 12;

BEGIN {
	use_ok( 'JavaScript::RPC::Server::CGI' )
};

use strict;
use warnings;
use CGI;

my $server = MyJSRPC->new;

isa_ok( $server, 'JavaScript::RPC::Server::CGI' );

my $query = CGI->new( {
	C  => 'jsrs6',
	F  => 'add',
	P0 => '[2]',
	P1 => '[1]',
	U  => '1092142818812'
} );

$server->query( $query );

SKIP: {
	eval "use IO::Capture::Stdout";
	skip 'IO::Capture::Stdout required', 1 if $@;

	my $capture = IO::Capture::Stdout->new;
	$capture->start;
	$server->process;
	$capture->stop;
	my @lines = $capture->read;
	my $text  = <<EOT1;
<html>
<head></head>
<body onload="p = document.layers?parentLayer:window.parent; p.jsrsLoaded( 'jsrs6' );">jsrsPayload:<br />
<form name="jsrs_Form">
<textarea name="jsrs_Payload" id="jsrs_payload">3</textarea>
</form>
</body>
</html>
EOT1

	is( join( '', $lines[ 1 ] ), $text );
}

$query = CGI->new( {
	C  => 'jsrs6',
	F  => '',
	P0 => '[2]',
	P1 => '[1]',
	U  => '1092142818812'
} );

$server->query( $query );

SKIP: {
	eval "use IO::Capture::Stdout";
	skip 'IO::Capture::Stdout required', 3 if $@;

	eval "use IO::Capture::Stderr";
	skip 'IO::Capture::Stderr required', 3 if $@;

	my $capturestdout = IO::Capture::Stdout->new;
	my $capturestderr = IO::Capture::Stderr->new;
	$capturestdout->start;
	$capturestderr->start;
	$server->process;
	$capturestdout->stop;
	$capturestderr->stop;
	my @lineserr = $capturestderr->read;
	my $texterr  = 'No function specified at ' . __FILE__ . " line 85\n";
	my @linesout = $capturestdout->read;
	my $textout  = <<EOT2;
<html>
<head></head>
<body onload="p = document.layers?parentlayer:window.parent; p.jsrsError( 'jsrs6', 'No function specified' );">No function specified</body>
</html>
EOT2
	is( join( '', @lineserr ), $texterr );
	is( $server->error_message, 'No function specified' );
	is( join( '', $linesout[ 1 ] ), $textout );
}

$query = CGI->new( {
	C  => 'jsrs6',
	F  => 'add2',
	P0 => '[2]',
	P1 => '[1]',
	U  => '1092142818812'
} );

$server->query( $query );

SKIP: {
	eval "use IO::Capture::Stdout";
	skip 'IO::Capture::Stdout required', 3 if $@;

	eval "use IO::Capture::Stderr";
	skip 'IO::Capture::Stderr required', 3 if $@;

	my $capturestdout = IO::Capture::Stdout->new;
	my $capturestderr = IO::Capture::Stderr->new;
	$capturestdout->start;
	$capturestderr->start;
	$server->process;
	$capturestdout->stop;
	$capturestderr->stop;
	my @lineserr = $capturestderr->read;
	my $texterr  = 'Specified function not implemented at ' . __FILE__ . " line 123\n";
	my @linesout = $capturestdout->read;
	my $textout  = <<EOT2;
<html>
<head></head>
<body onload="p = document.layers?parentlayer:window.parent; p.jsrsError( 'jsrs6', 'Specified function not implemented' );">Specified function not implemented</body>
</html>
EOT2
	is( join( '', @lineserr ), $texterr );
	is( $server->error_message, 'Specified function not implemented' );
	is( join( '', $linesout[ 1 ] ), $textout );
}

$query = CGI->new( {
	C  => 'jsrs6',
	F  => 'add',
	P0 => '[2]',
	U  => '1092142818812'
} );

$server->query( $query );

SKIP: {
	eval "use IO::Capture::Stdout";
	skip 'IO::Capture::Stdout required', 3 if $@;

	eval "use IO::Capture::Stderr";
	skip 'IO::Capture::Stderr required', 3 if $@;

	my $capturestdout = IO::Capture::Stdout->new;
	my $capturestderr = IO::Capture::Stderr->new;
	$capturestdout->start;
	$capturestderr->start;
	$server->process;
	$capturestdout->stop;
	$capturestderr->stop;
	my @lineserr = $capturestderr->read;
	my $texterr  = '2 numbers are needed at ' . __FILE__ . " line 160\n";
	my @linesout = $capturestdout->read;
	my $textout  = <<EOT2;
<html>
<head></head>
<body onload="p = document.layers?parentlayer:window.parent; p.jsrsError( 'jsrs6', '2 numbers are needed' );">2 numbers are needed</body>
</html>
EOT2
	is( join( '', @lineserr ), $texterr );
	is( $server->error_message, '2 numbers are needed' );
	is( join( '', $linesout[ 1 ] ), $textout );
}