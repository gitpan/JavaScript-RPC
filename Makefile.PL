use ExtUtils::MakeMaker;
WriteMakefile(
	NAME              => 'JavaScript::RPC',
	VERSION_FROM      => 'lib/JavaScript/RPC/Server/CGI.pm',
	PREREQ_PM    => {
		'Test::More' => 0
	},
);
