use ExtUtils::MakeMaker;
WriteMakefile(
	NAME          => 'JavaScript::RPC',
	VERSION_FROM  => 'lib/JavaScript/RPC/Server/CGI.pm',
	ABSTRACT      => 'Remote procedure calls from JavaScript',
	PREREQ_PM     => {
		'Test::More' => 0
	},
);
