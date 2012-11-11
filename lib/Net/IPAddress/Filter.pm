package Net::IPAddress::Filter;

use strict;
use warnings;

# ABSTRACT: A compact and fast IP Address range filter
# VERSION

=head1 NAME

Net::IPAddress::Filter - A compact and fast IP Address range filter

=head1 DESCRIPTION


=head1 SYNOPSIS

    my $filter = Net::IPAddress::Filter->new();

    $filter->add_rule('10.0.0.10', '10.0.0.50');
    $filter->add_rule('192.168.1.1');

    print "In filter\n" if $filter->filter('10.0.0.25');

=cut

use Set::IntervalTree;

=head2 new ( )

Constructs new blank filter object.

Expects:
    None.

Returns:
    Blessed filter object.

=cut

sub new {
    my $class = shift;

    my $self = { filter => Set::IntervalTree->new(), };

    return bless $self, $class;
}

=head2 add_rule( ) 

Expects:
    $start_ip - A dotted quad IP address string.
    $end_ip   - An optional otted quad IP address string. Defaults to $start_ip.

Returns:
    None.

=cut

sub add_rule {
    my ( $self, $start_ip, $end_ip ) = @_;

    my $start_num = _ip_address_to_number($start_ip);
    my $end_num = $end_ip ? _ip_address_to_number($end_ip) : $start_num;

    if ( $end_num < $start_num ) {
        ( $start_num, $end_num ) = ( $end_num, $start_num );
    }

    # Set::IntervalTree uses half-closed intervals, so need to go 1 higher and
    # lower than the actual ranges.
    $self->{filter}->insert( 1, $start_num - 1, $end_num + 1 );

    return;
}

=head2 filter( ) 

Test whether a given IP address is in one of the ranges in the filter.

Expects:
    $test_ip - A dotted quad IP address string.

Returns:
    1 if test IP is in one of the ranges.
    0 otherwise.

=cut

sub filter {
    my ($self, $test_ip) = @_;

    my $test_num = _ip_address_to_number($test_ip);

    my $found = $self->{filter}->fetch($test_num) || return 0;

    return scalar @$found ? 1 : 0;
}

=head2 _ip_address_to_number( ) 

Utility function to convert a dotted quad IP address to a number. 

TODO: Handle IPv6 addresses as well.

Expects:
    A dotted quad IP address string.

Returns:
    The integer representation of the IP address.

=cut

sub _ip_address_to_number {

    return unpack 'N', pack 'C4', split '\.', shift;

}

1;
