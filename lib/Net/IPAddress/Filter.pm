package Net::IPAddress::Filter;

# ABSTRACT: A compact and fast IP Address range filter

use strict;
use warnings;

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
    $start_ip : A dotted quad IP address string.
    $end_ip : An optional otted quad IP address string. Defaults to $start_ip.

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

    $self->{filter}->insert( 1, $start_num, $end_num );

    return;
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
