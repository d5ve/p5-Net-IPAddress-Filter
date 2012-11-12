#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);

use_ok('Net::IPAddress::Filter') or die "Unable to compile Net::IPAddress::Filter" ;

my $filter = new_ok('Net::IPAddress::Filter') or die "Unable to construct a Net::IPAddress::Filter";

# Check off-by-one errors for a single-address range.
is($filter->in_filter('192.168.1.0'), 0, "192.168.1.0 not yet in filter");
is($filter->in_filter('192.168.1.1'), 0, "192.168.1.1 not yet in filter");
is($filter->in_filter('192.168.1.2'), 0, "192.168.1.2 not yet in filter");
is($filter->add_range('192.168.1.1'), undef, "Adding 192.168.1.1 to filter");
is($filter->in_filter('192.168.1.0'), 0, "192.168.1.0 still not in filter");
is($filter->in_filter('192.168.1.1'), 1, "192.168.1.1 now in filter");
is($filter->in_filter('192.168.1.2'), 0, "192.168.1.2 still not in filter");

# Check off-by-one errors for an actual range.
is($filter->in_filter('10.1.100.0'), 0, "10.1.100.0 not yet in filter");
is($filter->in_filter('10.1.100.1'), 0, "10.1.100.1 not yet in filter");
is($filter->in_filter('10.1.100.2'), 0, "10.1.100.2 not yet in filter");
is($filter->in_filter('10.1.100.98'), 0, "10.1.100.98 not yet in filter");
is($filter->in_filter('10.1.100.99'), 0, "10.1.100.99 not yet in filter");
is($filter->in_filter('10.1.100.100'), 0, "10.1.100.100 not yet in filter");
is($filter->add_range('10.1.100.1', '10.1.100.99'), undef, "Adding ('10.1.100.1', '10.1.100.99') to filter");
is($filter->in_filter('10.1.100.0'), 0, "10.1.100.0 still not in filter");
is($filter->in_filter('10.1.100.1'), 1, "10.1.100.1 now in filter");
is($filter->in_filter('10.1.100.2'), 1, "10.1.100.2 now in filter");
is($filter->in_filter('10.1.100.98'), 1, "10.1.100.98 now in filter");
is($filter->in_filter('10.1.100.99'), 1, "10.1.100.99 now in filter");
is($filter->in_filter('10.1.100.100'), 0, "10.1.100.100 still not in filter");

# Check out-of-order range
is($filter->add_range('127.0.0.10', '127.0.0.1'), undef, "Adding ('127.0.0.10', '127.0.0.1') to filter");
is($filter->in_filter('127.0.0.5'), 1, "127.0.0.5 now in filter");

# Check zero-padded inputs a la ipfilter.dat
is($filter->add_range('127.000.000.099', '127.000.000.099'), undef, "Adding ('127.000.000.099', '127.000.000.099') to filter");
is($filter->in_filter('127.000.000.099'), 1, "127.000.000.099 now in filter");

# Check overlapping ranges
is($filter->add_range('172.16.0.100', '172.16.0.200'), undef, "Adding ('172.16.0.100', '172.16.0.200') to filter");
is($filter->add_range('172.16.0.199', '172.16.0.255'), undef, "Adding ('172.16.0.199', '172.16.0.255') to filter");
is($filter->in_filter('172.16.0.199'), 1, "172.16.0.199 now in filter");
is($filter->in_filter('172.16.0.200'), 1, "172.16.0.200 now in filter");
is($filter->in_filter('172.16.0.201'), 1, "172.16.0.201 now in filter");

done_testing;

