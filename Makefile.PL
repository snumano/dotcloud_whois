use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'whois',
    AUTHOR        => 'Some Person <person@example.com>',
    VERSION_FROM  => 'lib/whois.pm',
    PREREQ_PM     => {
        'CPAN::Meta::Requirements'        => '0',
        'Plack::Runner'                   => '0',
        'Amon2'                           => '3.31',
        'Text::Xslate'                    => '1.5006',
        'Test::More'                      => '0.98',
        'Amon2::DBI'                      => '0.06',
        'DBD::SQLite'                     => '1.33',
        'HTML::FillInForm::Lite'          => '1.09',
        'JSON'                            => '2.50',
        'Plack::Middleware::ReverseProxy' => '0.09',
        'Plack::Middleware::Session'      => '0',
        'Plack::Session'                  => '0.14',
        'Test::WWW::Mechanize::PSGI'      => '0',
        'Time::Piece'                     => '1.20',
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
