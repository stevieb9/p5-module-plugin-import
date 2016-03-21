package Plugin::Simple;
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use ExtUtils::Installed;
use Module::Load;

sub import {
    my ($class, %opts) = @_;

    my $pkg = (caller)[0];

    my $self = __PACKAGE__->new;

    my $sub = sub {
        shift if ref $_[0] eq $pkg;
        my $item = shift;

        my $action;

        my @plugins;

        if ($item){
            if (-e $item){
                @plugins = $self->_load($pkg, $item);
            }
            else{ 
                @plugins = $self->_search($pkg, $item);
            }
        }
        if (! @plugins){    
            @plugins = $self->_search($pkg);
        }
        return @plugins;
    }
}    
sub new {
    return bless {}, shift;
}
sub _search {
    my ($self, $pkg, $item) = @_;

    my $inst = ExtUtils::Installed->new;
    my @modules = $inst->modules;

    my @plugins;

    if ($item){
        @plugins = grep { $_ =~ /^$item/ } @modules;
    }
    else {
        my $path = $pkg;
        $path .= '::Plugin';
        @plugins = grep { $_ =~ /^$path/ } @modules;
    }

    my @loaded;

    for (@plugins){
        my $ok = $self->_load($_);
        push @loaded, $ok;
    }

    return @plugins;
}
sub _load {
    my $plugin = shift;

    if ($plugin =~ /(.*)\W(\w+)\.pm/){
        unshift @INC, $1,
        $plugin = $2;
    }
    elsif ($plugin =~ /(?<!\W)(\w+)\.pm/){
        unshift @INC, '.';
        $plugin = $1;
    }

    my $loaded = eval { load $plugin; 1; };

    if ($loaded) {
        print "loaded $plugin\n";
        return $plugin;
    }
    else {
       print "failed to load $plugin\n"; 
       return 0;
    }       
}
1;
