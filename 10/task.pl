#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

# CPU State
my $clock = 1;
my $x = 1;

my %instruction = (
    noop => [ 1, sub { 1;} ],
    addx => [ 2, sub { $x += shift } ]
);

# Task 1, Sampling
my $next = 20;
my $step = 40;
my $total = 0;

# Task 2: Screen handling
sub update {
    my $pos = ($clock - 1) % 40;

    print (abs($x-$pos) <= 1 ? "#" : ".");
    print "\n" if $pos == 39;
}

# Instruction loop
while (<>) {
    chomp;
    my ($cmd, @param) = split / /;

    my $delta = $instruction{$cmd}->[0];

    if ($clock + $delta > $next) {
        $total += $next * $x;
        $next += $step;
    }

    while ($delta--) {
        update();
        $clock++;
    }

    $instruction{$cmd}->[1]->(@param);
}

say "";
say "Clock: $clock";
say "Next sample: $next";
say "";
say "Task 1: $total";

