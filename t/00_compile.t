use strict;
use warnings;
use utf8;
use Test::More;

use_ok $_ for qw(
    whois
    whois::Web
    whois::Web::Dispatcher
);

done_testing;
