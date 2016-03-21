package Module::Plugin::Import::State;

use 5.006;
use strict;
use warnings;

sub new {
    return bless {}, shift;
}
sub set {
    my ($self, %opts) = @_;
    for (keys %opts){
        $self->$_($opts{$_}) if exists &$_;
    }
}
my sub_name {
    my ($self, $sub) = @_;
    if ($sub){
        $self->{sub} = $sub;
    }
    return $sub;
}
