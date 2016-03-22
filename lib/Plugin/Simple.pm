package Plugin::Simple;
use 5.006;
use strict;
use warnings;

use Carp qw(croak);
use Module::List qw(list_modules);
use Module::Load;

our $VERSION = '0.06';

my $self;

sub import {
    my ($class, %opts) = @_;

    $self = __PACKAGE__->_new(%opts);

    my $sub_name = $opts{sub_name} ? $opts{sub_name} : 'plugins';

    {
        no warnings 'redefine';
        no strict 'refs';

        my $pkg = (caller)[0];
        *{"$pkg\::$sub_name"} = \&_plugins;
    }
}
sub _new {
    my ($class, %args) = @_;
    my $self = bless \%args, $class;

    return $self;
}
sub _search {
    my ($self, $pkg, $item) = @_;

    my @plugins;

    if ($item){
        if ($item !~ /::$/){
            push @plugins, $item;
        }
        else {
            my $candidates;
            eval { $candidates = list_modules(
                    $item,
                    {list_modules => 1, recurse => 1}
                );
            };
            push @plugins, keys %$candidates;
        }
    }
    else {
        my $path = $pkg;
        $path .= '::Plugin::';
        my $candidates = {};
        eval { $candidates = list_modules(
                $path,
                {
                    list_modules => 1,
                    recurse => 1}
                );
        };
        push @plugins, keys %$candidates;
    }

    my @loaded;

    for (@plugins){
        my $ok = $self->_load($_);
        push @loaded, $ok;
    }

    return @loaded;
}
sub _load {
    my ($self, $plugin) = @_;

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
        return $plugin;
    }
}
sub _plugins {
    shift if ref $_[0]; # dump the calling object if present

    my ($item, $can);

    if ($_[0] && $_[0] eq 'can'){
        shift;
        $can = shift;
    }
    else {
        $item = shift;
        shift;
        $can = shift;
    }

    if (@_){
        croak "usage: plugin(['Load::From'], [can => 'sub']), " .
              "in that order\n";
    }

    my $pkg = (caller)[0];
    my @plugins;

    if ($item){
        if ($item =~ /(?:\.pm|\.pl)/){
            if (-e $item){
                @plugins = $self->_load($item);
            }
        }
        else{
            @plugins = $self->_search($pkg, $item);
        }
    }
    if (! @plugins){
        @plugins = _search($pkg);
    }
    if (! $plugins[0] && $self->{default}){
        push @plugins, $self->_load($self->{default});
    }

    my @wanted_plugins;

    if ($can) {
        for my $mod (@plugins){
            my $can_count = 0;
            for my $sub (@$can){
                if ($mod->can($sub)){
                    $can_count++;
                }
            }
            push @wanted_plugins, $mod if $can_count == @$can;
        }
        return wantarray ? @wanted_plugins : $wanted_plugins[0];
    }

    return wantarray ? @plugins : $plugins[0];
}

1;

=head1 NAME

Plugin::Simple - Load plugins from files or modules.

=for html
<a href="http://travis-ci.org/stevieb9/p5-plugin-simple"><img src="https://secure.travis-ci.org/stevieb9/p5-plugin-simple.png"/>
<a href='https://coveralls.io/github/stevieb9/p5-plugin-simple?branch=master'><img src='https://coveralls.io/repos/stevieb9/p5-plugin-simple/badge.svg?branch=master&service=github' alt='Coverage Status' /></a>

=head1 SYNOPSIS

    use Plugin::Simple;

    # load a plugin module from a file

    @plugins = plugins('/path/to/MyModule.pm');

    # load all modules under '__PACKAGE__::Plugin' namespace

    my @plugins = plugins(); # call in scalar context to retrieve the first one

    # load all plugins under a specific namespace (note the trailing ::)

    @plugins = plugins('Any::Namespace::');

    # load/return only the plugins that can perform specific functions

    @plugins = plugins(can => ['foo', 'bar]); # foo and bar

    # instead of importing 'plugins()', change the name:

    use Plugin::Simple sub_name => 'foo';
    @plugins = foo(...);

    # set a default fallback plugin if searching turns up nothing

    use Plugin::Simple default => 'My::Module::Plugin::DefaultPlugin'

    # do something with the plugins

    for my $plugin (@plugins){
        $plugin->plugin_func(@args);
    }

    # works in OO modules too simply by using it

    my @plugins = $self->plugins();

=head1 DESCRIPTION

There are many plugin modules available on the CPAN, but I wrote this one just
for fun. It's very simple, extremely lightweight, and is extremely minimalistic
in what it does.

It searches for modules in installed packages or non-installed files, and loads
them (without string C<eval>). You can optionally have us return only the
plugins that C<can()> perform a specific task.

=head1 LOAD OPTIONS

By default, we force C<plugins()> into your namespace. To change this name:

    use Plugin::Simple sub_name => 'other_name';

If searching fails, you can ensure a default known plugin gets loaded:

    use Plugin::Simple default => 'My::Plugin';

To use both options, simply separate them with a comma.

=head1 FUNCTIONS/METHODS

None. We simply install a C<plugin()> function within the namespace of the
package that C<use>d us.

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head2 CONTRIBUTING

Any and all feedback and help is appreciated. A Pull Request is the preferred
method of receiving changes (L<https://github.com/stevieb9/p5-plugin-simple>),
but regular patches through the bug tracker, or even just email discussions are
welcomed.

=head1 BUGS

L<https://github.com/stevieb9/p5-plugin-simple/issues>

=head1 SUPPORT

You can find documentation for this script and module with the perldoc command.

    perldoc Plugin::Simple;

=head1 SEE ALSO

There are far too many plugin import modules on the CPAN to mention here.

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

