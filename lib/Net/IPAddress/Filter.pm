package Net::IPAddress::Filter;

use strict;
use warnings;

# ABSTRACT: A compact and fast IP Address range filter
# VERSION

=head1 SYNOPSIS

    my $filter = Net::IPAddress::Filter->new();

    $filter->add_range('10.0.0.10', '10.0.0.50');
    $filter->add_range('192.168.1.1');

    print "In filter\n" if $filter->in_filter('10.0.0.25');

=head1 DESCRIPTION

Net::IPAddress::Filter uses the XS module L<Set::IntervalTree> under the hood.
An Interval Tree is a data structure optimised for fast insertions and searches
of ranges, so sequential scans are avoided. The XS tree data structure is more
compact than a pure Perl version of the same.

In initial testing on an AMD Athlon(tm) 64 X2 Dual Core Processor 4200+,
Net::IPAddress::Filter did about 60k range inserts/sec, and about 100k
lookups per second. The process memory size grew by about 1MB per 7,500 ranges
inserted.

=cut

use Set::IntervalTree;    # XS module.

=method new ( )

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

=method add_range( )

Expects:
    $start_ip - A dotted quad IP address string.
    $end_ip   - An optional dotted quad IP address string. Defaults to $start_ip.

Returns:
    None.

=cut

sub add_range {
    my ( $self, $start_ip, $end_ip ) = @_;

    my $start_num = _ip_address_to_number($start_ip);
    my $end_num = $end_ip ? _ip_address_to_number($end_ip) : $start_num;

    # Guarantee that the start <= end
    if ( $end_num < $start_num ) {
        ( $start_num, $end_num ) = ( $end_num, $start_num );
    }

    # Set::IntervalTree uses half-closed intervals, so need to go 1 higher and
    # lower than the actual ranges.
    $self->{filter}->insert( 1, $start_num - 1, $end_num + 1 );

    return;
}

=method in_filter( )

Test whether a given IP address is in one of the ranges in the filter.

Expects:
    $test_ip - A dotted quad IP address string.

Returns:
    1 if test IP is in one of the ranges.
    0 otherwise.

=cut

sub in_filter {
    my ( $self, $test_ip ) = @_;

    my $test_num = _ip_address_to_number($test_ip);

    my $found = $self->{filter}->fetch( $test_num, $test_num ) || return 0;

    return scalar @$found ? 1 : 0;
}

=func _ip_address_to_number( )

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

__END__

=pod

=head1 TODO

=for :list
* Support for IPv6 Addresses. This would need a lot of work, as
Set::IntervalTree uses long ints internally, and IPv6 needs 128-bit numbers.

=head1 SEE ALSO

=for :list
* L<Config::IPFilter> - Moose-based pure Perl IP address filter.
* L<Net::BitTorrent::Network::IPFilter> - Moose-based pure Perl IP address filter.
* L<NET::IPFilter> - Pure Perl extension for Accessing eMule / Bittorrent
IPFilter.dat Files and checking a given IP against this ipfilter.dat IP Range.

=cut
