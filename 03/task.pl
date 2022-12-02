#!//usr/bin/perl

use v5.34;
use experimental 'signatures';

use List::Util qw(all);

sub divide($string) {
    my $half = length($string) / 2;
    return ( substr($string, 0, $half), substr($string, $half) );
}

sub lookup($char) {
    return ord($char) - 96 if $char =~ /[a-z]/;
    return ord($char) - 38 if $char =~ /[A-Z]/;
    return 0;
}

sub score($first, @rest) {
    for my $c (split //, $first) {
	return lookup($c) if all { $_ =~ /$c/ } @rest;
    }

    return 0;
}

my $total = 0;
my $badge = 0;
my @group = ();
while(<>) {
    chomp;

    $total += score(divide($_));

    push @group, $_;
    if (@group == 3) {
	$badge += score(@group);
	@group = ();
    }
}

say "Total: $total";
say "Badges: $badge";

