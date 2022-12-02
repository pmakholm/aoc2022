#!//usr/bin/perl

use v5.34;
use experimental 'signatures';

sub contains($first, $second) {
    $second->[1] <= $first->[1]
}

sub overlaps($first, $second) {
    $first->[1] >= $second->[0]
}

my @elves = map {
               [ sort { $a->[0] <=> $b->[0] || $b->[1] <=> $a->[1] } @$_ ] # Sort elves by starting section
            }
	    map { [ map { [ split /-/ ] } @$_ ] }
	    map { [ split /,/ ] }
	    <>;

my @contains = grep { contains(@$_) } @elves;
my @overlaps = grep { overlaps(@$_) } @elves;

say "Fully Contains: ", scalar @contains;
say "Overlaps: ", scalar @overlaps;
