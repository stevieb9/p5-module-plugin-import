package Module::Plugin::Import;

use 5.006;
use strict;
use warnings;

use Data::Dumper;
use ExtUtils::Installed;
use Module::Load;

sub import {
    my $class = shift;
    my %opts = @_;

sub plugins {
    my $from = shift;
    
    my $inst = ExtUtils::Installed->new;
    my @modules = $inst->modules;

    my $pkg = _caller();
    $plugin_loc = _from($from) ? _from($from) : "$pkg::Plugin::";

    my @plugins = grep /^$plugin_loc/, @modules;

    for (@plugins){
        load $_;
    }
}
sub _caller {
    my ($pkg, $file) = caller;
    return $pkg;
}
sub _from {
    my $loc = shift;
    if ($loc){
        $loc .= ($loc =~ /::$/) ? '' : '::';
    }
    return $loc;
}
sub _export_symbols {

=head1 NAME

Module::Plugin::Import - The great new Module::Plugin::Import!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Module::Plugin::Import;

    my $foo = Module::Plugin::Import->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-module-plugin-import at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Module-Plugin-Import>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Module::Plugin::Import


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Module-Plugin-Import>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Module-Plugin-Import>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Module-Plugin-Import>

=item * Search CPAN

L<http://search.cpan.org/dist/Module-Plugin-Import/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of Module::Plugin::Import
