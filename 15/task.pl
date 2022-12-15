#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

use List::Util qw(any reduce);
use List::MoreUtils qw(minmax);

my @input = map { s/\s*//r } <>;

sub dist($a, $b) {
    return abs($a->[0] - $b->[0]) + abs($a->[1] - $b->[1]);
}

sub parse($line) {
    $line =~ /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/;

    return [ [ $1, $2, dist([$1, $2], [$3, $4])], [$3, $4] ];
}

sub covers($sensor, $point) {
    return dist($sensor, $point) <= $sensor->[2];
}

sub relevant($target_y, $sensor) {
    return dist($sensor, [ $sensor->[0], $target_y]) <= $sensor->[2];
}

my @sensors;
my %beacons;
my ($min_x, $max_x);
for my $entry (map { parse $_ } @input) {
    my ($sensor, $beacon) = @$entry;

    push @sensors, $sensor;

    $min_x = $min_x < $sensor->[1] - $sensor->[2] ? $min_x : $sensor->[1] - $sensor->[2];
    $max_x = $max_x > $sensor->[1] + $sensor->[2] ? $max_x : $sensor->[1] + $sensor->[2];

    $beacons{$beacon->[1]}{$beacon->[0]} = 1;
}


# Task 1:
# my $target_y = 10;
my $target_y = 2000000;

my @coverage = sort { $a->[0] <=> $b->[0] }                          # Sort by right end
               map { [ $_->[0] - $_->[3], $_->[0] + $_->[3] ] }      # Create coverage
               grep { $_->[3] >= 0 }                                 # Filter out where diameter is negative
               map { [ @$_, $_->[2] - abs( $_->[1] - $target_y) ] }  # Add "diameter" of coverage of target line 
               @sensors;

my @merged = (shift @coverage);
for my $cover (@coverage) {
    # Fully disjunct
    if ($cover->[0] > $merged[-1][1]) {
        push @merged, $cover;
        next;
    }

    # Fully covered
    next if $cover->[1] <= $merged[-1][1];

    # Merge 
    $merged[-1][1] = $cover->[1]
}

my $count = reduce { $a + ($b->[1] - $b->[0] + 1) } 0, @merged;

$count -= scalar( keys %{ $beacons{$target_y} } );

say "Task 1: $count";

my ($x, $y) = (0,0);
my $best_y = 1;

while(1) {
    my @candidates = grep { covers($_, [ $x, $y ]) } @sensors;

    last unless @candidates;
    my $sensor = shift @candidates;

    my $delta = $sensor->[0] - $x;

    $x++ if $delta == 0;

    my $diameter = ($sensor->[2] - abs( $sensor->[1] - $y ));

    $x += $diameter + $delta + 1;
} continue {
    if ($x > 4000000 ) {
        $x = 0;
        $y++;
    }

    last if $y > 4000000;
}

my $freq = 4000000 * $x + $y;
say "Task 2: $freq";


