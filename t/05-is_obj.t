#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use Plugin::Simple;

use lib 't/base';
use TestPackage;

{
    my $obj = TestPackage->new;
    can_ok($obj, 'plugins');

    is ($obj->plugins, 0, "an obj call to plugins works");
    is ($obj->plugins('t/base/Testing.pm'), 1, "an obj call to plugins with file works");
}

done_testing();

