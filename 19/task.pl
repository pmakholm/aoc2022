#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

use List::Util qw(all any min max);

# Initially I branched out each minute, with all possible actions, but I
# was not able to prune the search space sufficiently.
#
# Then I decided to branch out on which robot to build next. This works, but
# my solution is still heavily influenced by my initial approach. Would have
# coded it differently if I hadn't spend so much time on getting pruning work
# in my initial attempt.
#
# Still not fast, but it works..
# - I'm done with Day 19!

sub add($x, $y) {
    die if $x->$#* != $y->$#*;

    return [ map { $x->[$_] + $y->[$_] } 0..$x->$#* ]
}

my @valid = (
    sub ($state, $blueprint) { 1 },
    sub ($state, $blueprint) { $state->[9] == 1 && all { $state->[$_] >= $blueprint->[0][$_] } 0..3 },
    sub ($state, $blueprint) { $state->[9] == 2 && all { $state->[$_] >= $blueprint->[1][$_] } 0..3 },
    sub ($state, $blueprint) { $state->[9] == 3 && all { $state->[$_] >= $blueprint->[2][$_] } 0..3 },
    sub ($state, $blueprint) { $state->[9] == 4 && all { $state->[$_] >= $blueprint->[3][$_] } 0..3 },
);

my @forward = (
    sub ($state, $blueprint) { [ $state->@[4..7], 0, 0, 0, 0, 1, 0 ] },
    sub ($state, $blueprint) { [ (map { $state->[$_ + 4] - $blueprint->[0][$_] } 0..3),  1, 0, 0, 0, 1, -1 ] },
    sub ($state, $blueprint) { [ (map { $state->[$_ + 4] - $blueprint->[1][$_] } 0..3),  0, 1, 0, 0, 1, -2 ] },
    sub ($state, $blueprint) { [ (map { $state->[$_ + 4] - $blueprint->[2][$_] } 0..3),  0, 0, 1, 0, 1, -3 ] },
    sub ($state, $blueprint) { [ (map { $state->[$_ + 4] - $blueprint->[3][$_] } 0..3),  0, 0, 0, 1, 1, -4 ] },
);

sub wasted($state, $max) {
    # Never build robots, if you alread collects the maximun
    # usable resources each round.

    my $robots = any { $state->[$_+4] > $max->[$_] } 0..3;

    return $robots;
}

sub possible($state) {
    # Only try to build robots, if you collect the required resources

    return 0 if $state->[9] == 3 && $state->[5] < 1;
    return 0 if $state->[9] == 4 && $state->[6] < 1;
    return 1;
}

sub geodes( $blueprint, $rounds ) {
    # State is
    #   [0..3] Amount of resources of each type
    #   [4..7] Number of robots of each type
    #   [8]    Time
    #   [9]    Next robot to build
    my $init = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0];

    my $max = [
        (max map { $_->[0] } @$blueprint),
        (max map { $_->[1] } @$blueprint),
        (max map { $_->[2] } @$blueprint),
        $rounds
    ];

    my $geodes = 0;

    my $solutions = 0;
    my @work = ($init);
    while (@work) {
        my $state = pop @work;

        if ( $state->[8] == $rounds ) {
            $geodes = $state->[3] > $geodes ? $state->[3] : $geodes;
            #            say "Solution: $state->[3] (max: $geodes) [", join(",", @$state), "]";
            next;
        }

        my @valid = grep { $valid[$_]->($state, $blueprint) } 0..4;

        # Never just collect, if you can build the target robot.
        if (@valid > 1) { shift @valid }

        my @new = 
            grep { possible($_) }
            map  {
                $_->[9] == 0 ?
                    (
                    [ $_->@[0..8], 4 ],
                    [ $_->@[0..8], 3 ],
                    [ $_->@[0..8], 2 ],
                    [ $_->@[0..8], 1 ])
                : $_;
            }
            grep { not wasted($state, $max) } 
            map  { add( $state, $forward[$_]->($state, $blueprint) ) }
            @valid;

        push @work, @new;
    }

    return $geodes;
}

my @input = map { s/\s*$//r } <>;

my $total  = 0;
for (@input) {
    my @data = ($_ =~ /(\d+)/g);

    my $index = @data[0];
    my $blueprint =  [ [$data[1], 0, 0, 0], [$data[2], 0, 0, 0], [$data[3], $data[4], 0, 0], [$data[5], 0, $data[6], 0 ] ];

    my $geodes = geodes( $blueprint, 24 );
    say "Input (", join(", ", @data), ") found $geodes geodes";
    $total += $index * $geodes;
}

say "Task 1: $total";

my $total  = 1;
for (@input[0..2]) {
    my @data = ($_ =~ /(\d+)/g);

    my $index = @data[0];
    my $blueprint =  [ [$data[1], 0, 0, 0], [$data[2], 0, 0, 0], [$data[3], $data[4], 0, 0], [$data[5], 0, $data[6], 0 ] ];

    my $geodes = geodes( $blueprint, 32 );
    say "Input (", join(", ", @data), ") found $geodes geodes";
    $total *= $geodes;
}

say "Task 2: $total";
