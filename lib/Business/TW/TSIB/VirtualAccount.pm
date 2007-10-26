package Business::TW::TSIB::VirtualAccount;

use warnings;
use strict;
use Business::TW::TSIB::VirtualAccount::Entry;

=head1 NAME

Business::TW::TSIB::VirtualAccount - Module for Taishin Bank Virtual Account Management

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

=head1 SYNOPSIS

    use Business::TW::TSIB::VirtualAccount;
    my $va  = Business::TW::TSIB::VirtualAccount->new({ corp_code => '9528' });
    my $acc = $va->generate( { due    => DateTime->new( year => 2007, month => 4, day => 2 )
                               amount => 3900,
                               ar_id  => '20892' } );
    # $acc should be '95286092208929'  
    # total 14 columns
    
    my $entries = Business::TW::TSIB::VirtualAccount->parse_summary($fh);

    # entries is arrayref of Business::TW::TSIB::VirtualAccount::Entry objects,
    # which has the following accessors:
    # seqno
    # date
    # amount
    # virtualaccount
    # ar_id
    # code
    # postive
    # orig_bank

=head1 DESCRIPTION

This module provides utility functions for the virtual account service
by TSIB (Taishin International Bank, Taiwan).

=head1 METHODS

=head2 new( { corp_code => $corp_code} )

Initialize the virtual account context with C<corp_code> provided by
TSIB.

=cut

sub new {
    my $class = shift;
    my $args = shift;
    my $self = {};
    die("No Given Corperation Code") if ( ! exists( $args->{corp_code} ));

    $self->{corp_code} = $args->{corp_code};

    return bless $self , $class;
}

=head2 $va->generate( $args )

Generate a virtual account with the given arguments.  $args is a hash ref and must contain:

=over

=item due

A L<DateTime> object for due day of the payment

=item amount

The expected amount of the transaction.

=item ar_id

The arbitary account receivable identifier.

=back

=cut

sub generate {
    my $self = shift;
    my $args = shift;

    map { die("No Given $_") if ( !exists( $args->{$_} ) ) } qw/due amount ar_id/;

    # gen account
    my $date_code = sprintf( "%d%03d",
        ( $args->{due}->year - 1 ) % 10,
        $args->{due}->day_of_year );
    my $account = $self->{corp_code} . $date_code . $args->{ar_id} ;

    die("Account Generation Error") if ( length($account) != 13 );

    return $self->_gen_checksum( $account , $args );
}


sub _gen_checksum {
    my $self    = shift;
    my $account = shift;
    my $args    = shift;

    # gen amount code
    my @as = reverse split( //, "$args->{amount}" );

    my $amount_code = 0;
    map {
        $amount_code += ( ( $as[$_] || 0 ) + ( $as[ 6 - $_ ] || 0 ) ) * ( 5 - $_ )
    } ( 0, 1, 2 );
    $amount_code += ( $as[3] || 0 ) * 2;

    # gen checksum
    my @c = split( //, $account );
    die('Wrong Account') if ( $#c + 1 != 13 );

    my @c_odd = @c[ 0, 2, 4, 6, 8, 10, 12 ];
    my @c_even = @c[ 1, 3, 5, 7, 9, 11 ];

    my ( $sum_odd, $sum_even ) = ( 0, 0 );
    map { $sum_odd  += $_; } @c_odd;
    map { $sum_even += $_; } @c_even;
    my $checksum = 10 - ( ( $sum_odd * 3 + $sum_even + $amount_code ) % 10 );
    return $account . $checksum;

}

=head2 $self->parse_summary($fh)

=cut

sub parse_summary {
    my $class = shift;
    my $fh = shift;

    my @entries;
    while( <$fh> ) {
        my %col_hash = ();
        @col_hash{qw(seqno date amount virtualaccount ar_id code postive orig_bank)} = split /\s+/;
        my $entry = Business::TW::TSIB::VirtualAccount::Entry->new( \%col_hash );
        push @entries , $entry;
    }
    return \@entries;
}

=head1 AUTHOR

Chia-liang Kao, C<< <clkao AT aiink.com> >> ,
You-An Lin, C<< <c9s AT aiink.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-business-tw-taishinbank-virtualaccount at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Business-TW-TSIB-VirtualAccount>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Business::TW::TSIB::VirtualAccount

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Business-TW-TSIB-VirtualAccount>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Business-TW-TSIB-VirtualAccount>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-TW-TSIB-VirtualAccount>

=item * Search CPAN

L<http://search.cpan.org/dist/Business-TW-TSIB-VirtualAccount>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 AIINK co., ltd, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut





1; # End of Business::TW::TSIB::VirtualAccount
