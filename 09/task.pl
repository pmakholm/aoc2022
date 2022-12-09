#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

# This is just the standard sign function. 
sub signum($i) {
    return -1 if $i < 0; 
    return 0  if $i == 0;
    return 1  if $i > 0;

    die "signum called with non-integer";
}

sub follow($head,$tail) {
    my $delta = [ 
        $head->[0] - $tail->[0],
        $head->[1] - $tail->[1]
    ];

    # Knots are touching
    if (abs($delta->[0]) <= 1 && abs($delta->[1]) <= 1) {
        return [0, 0];
    }

    # Originally the orthogonal and diagonal cases were handled
    # seperately. But writing each case, it is easy to see that
    # they collapses into this:
    return [ signum($delta->[0]), signum($delta->[1]) ];
}

sub step($knot, $delta) {
    $knot->[0] += $delta->[0];
    $knot->[1] += $delta->[1];
}

my %DIRECTION = (
    R => [1,0],
    L => [-1,0],
    U => [0,1],
    D => [0,-1],
);

# Originally I made two passes of the input. Once with an explicit head and
# tail and once with a rope. On clean-up it is obvious that Task 1 is just
# a rope of length 2.
sub doit($direction, $rope, $coverage) {
    step($rope->[0], $DIRECTION{$direction});
    step($rope->[$_], follow($rope->[$_-1],$rope->[$_])) for (1..$#{ $rope });

    $coverage->{ $rope->[-1][0], $rope->[-1][1] } = 1;
}

# Setup task 1;
my @rope1 = map { [0, 0] } (0..1);
my %coverage1;

# Setup task2:
my @rope2 = map { [0, 0] } (0..9);
my %coverage2;

while (<>) {
    my ($direction, $steps) = split / /;

    while ($steps--) {
        doit($direction, \@rope1, \%coverage1);
        doit($direction, \@rope2, \%coverage2);
    }
}

say "Task 1: ", scalar keys %coverage1;
say "Task 2: ", scalar keys %coverage2;
