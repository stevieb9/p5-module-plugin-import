#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;
use Plugin::Simple;
use Test::More;

my $obj = Plugin::Simple->_new();
$obj = $obj->_config(a => 1, b => 2);

is ($obj->{a}, 1, "_config() does the right thing for a");
is ($obj->{b}, 2, "_config() does the right thing for b");

done_testing();

