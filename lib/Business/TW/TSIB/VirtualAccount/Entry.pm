package Business::TW::TSIB::VirtualAccount::Entry;
use strict;
use warnings;

use base qw(Class::Accessor);
__PACKAGE__->mk_accessors( qw(seqno date amount virtualaccount ar_id code postive orig_bank) );

# columns
#
# seqno             C
# date              C
# amount            N
# virtualaccount    C
# ar_id             C
# code              C
# postive           C
# orig_bank         C

sub new {
    my $class = shift;
    my $self = shift;
    $self->{amount} = int( $self->{amount} );
    return bless $self , $class;
}

1;

