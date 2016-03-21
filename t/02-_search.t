#!/usr/bin/perl
use strict;
use warnings;

use Plugin::Simple;
use Test::More;

my $ps = Plugin::Simple->_new;

{ # empty search
    my @ret = $ps->_search('main');
    is (@ret, 0, "#FIXME: by default, empty search returns nothing");
}
SKIP: { # module test
    my @ret = $ps->_search('main', 'DateTime');

    skip 'test mod not installed', 2, unless defined $INC{'DateTime.pm'};
    is (@ret, 5, "with an example item, things appear ok");
    can_ok('DateTime', 'new');
};

done_testing();

