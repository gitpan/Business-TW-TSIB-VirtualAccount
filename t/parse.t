#!/usr/bin/perl -T
use Test::More tests => 5;
BEGIN {
	use_ok( 'Business::TW::TSIB::VirtualAccount' );
}

diag( "Testing Business::TW::TSIB::VirtualAccount $Business::TW::TSIB::VirtualAccount::VERSION, Perl $], $^X" );


# create test file
my $content =<<EOF;
1          2006/01/27 000000000001000 9528609223492        REM  +                123
2          2006/01/27 000000000002000 9528609220892        REM  +                123
3          2006/01/27 000000000002000 9528609221232        REM  +                123
EOF

open my $fh,'>','tmp.dat';
print $fh $content;
close $fh ;

open my $fh , '<', 'tmp.dat';
my $entries = Business::TW::TSIB::VirtualAccount->parse_summary( $fh );
#use Data::Dumper::Simple;
#warn Dumper( $entries );
is( $entries->[0]->seqno , 1 );
is( $entries->[0]->amount , 1000 );
is( $entries->[1]->date , '2006/01/27' );
is( $entries->[1]->virtualaccount , '9528609220892' );
close $fh;

unlink 'tmp.dat';
