#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

use List::Util qw(max min);

# An obvious optimization over the naive "simulate each grain of sand" is to
# record the path of each grain and then backtrack the path of the previous
# grains.
#
# In my original submission, I didn't make this optimization. But it only 
# requires a few lines of code and improves the performance with a factor
# of 10.

sub add_segment($start, $end, $grid) {
    for my $x (min($start->[0], $end->[0]) .. max($start->[0], $end->[0])) {
        for my $y (min($start->[1], $end->[1]) .. max($start->[1], $end->[1])) {
            $grid->{$x}{$y} = 1;
        }
    }
}

sub make_grid(@input) {
    my $grid = {};
    my $depth = 0;

    for my $line (@input) {
        my @point = map { [ split /,/, $_ ] } split / -> /, $line;

        $depth = $depth > $_->[1] ? $depth : $_->[1] for @point; 

        for my $segment (0 .. $#point - 1) {
            add_segment($point[$segment], $point[$segment+1], $grid);
        }
    }

    return ($grid, $depth);
}

sub draw_grid($grid, $depth) {
    for my $y (0..$depth) {
        for my $x (360 .. 550) {
            print "#" if $grid->{$x}{$y} == 1;
            print "o" if $grid->{$x}{$y} == 2;
            print "." unless $grid->{$x}{$y};
        }
        print "\n";
    }
}

sub add_sand($grid, $depth, $path, $floor=0) {
    my ($x, $y);

    if (@$path > 2) {
        pop @$path;
        ($x, $y) = @{ pop @$path };
    } else {
        ($x, $y) = (500, 0);
    }

    # No space for any sand;
    return 0 if $grid->{500}{0};

    while(1) {
        push @$path, [ $x, $y ];

        if ($floor) {
            if ($y == $depth + 1) {
                $grid->{$x}{$y} = 2;
                return 1;
            }

        } else {
            return 0 if $y > $depth;
        }

        unless ($grid->{$x}{$y+1}) {
            $y++;
            next;
        }

        unless ($grid->{$x-1}{$y+1}) {
            $y++;
            $x--;
            next;
        }

        unless ($grid->{$x+1}{$y+1}) {
            $y++;
            $x++;
            next;
        }

        $grid->{$x}{$y} = 2;
        return 1;
    }
}

my @input = map { s/\s*$//r } <>;
my ($grid, $depth)= make_grid(@input);

my $path = [];
my $count = 0;
while (add_sand($grid, $depth, $path)) {
    $count++;
}

say "Task 1: $count";

my ($grid, $depth)= make_grid(@input);

my $path = [];
my $count = 0;
while (add_sand($grid, $depth, $path, 1)) {
    $count++;
}

say "Task 2: $count";

