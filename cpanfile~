use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'whois',
    AUTHOR        => 'Some Person <person@example.com>',
    VERSION_FROM  => 'lib/whois.pm',
    PREREQ_PM     => {
        'Plack'                           => '0',
        'Plack::Runner'                   => '0',
        'Plack::Session'                  => '0', 
        'Plack::Middleware::ReverseProxy' => '0',
        'Plack::Middleware::Session'      => '0',
        'Amon2'                           => '0',
        'Amon2::Plugin::DBI'              => '0',
        'Amon2::DBI'                      => '0',
        'Text::Xslate'                    => '0',
        'Test::More'                      => '0',
        'DBD::SQLite'                     => '0',
        'HTML::FillInForm::Lite'          => '0',
        'JSON'                            => '0',
        'Test::WWW::Mechanize::PSGI'      => '0',
        'Time::Piece'                     => '0',
        'Net::DNS'                        => '0',
        'Web::Scraper'                    => '0',
        'URI'                             => '0',
        'Encode'                          => '0',
        'Text::Xslate::Util'              => '0',
    },
    MIN_PERL_VERSION => '5.008001',
    (-d 'xt' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => 't/*.t xt/*.t',
        },
    ) : (),
);
