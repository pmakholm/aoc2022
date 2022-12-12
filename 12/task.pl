#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

use List::Util qw(reduce);

# For task 1, the start is marked with an 'S'.
# For task 2, the start is any location marked with 'a';
# (This assumes that there are a shorter path not starting at 'S')
my $start = 'a';

sub new($x,$y,$mark) {
    my $heigth = ord($mark);

    # Special casing start and end
    $heigth = ord('a') if $mark eq 'S';
    $heigth = ord('z') if $mark eq 'E';
    
    return {
        pos => [ $x, $y ],
        heigth => $heigth,
        visited => 0,
        steps => $mark eq $start ? 0 : 99999,
        end => $mark eq 'E',
    }
}

my @grid;
my $x = 0;
while(<>) {
    chomp;

    my $y = 0;
    my @line = map { new($x, $y++, $_) } split //;

    push @grid, \@line;
    $x++;
}

my $max_x = $#grid;
my $max_y = $#{ $grid[0] };
my $item;

# Do the Dijkstra dance...
while (1) {
    # Quick and dirty. Optimize for development time.
    # A priority list of unvisited nodes would be faster
    $item = reduce { $a->{steps} <= $b->{steps} ? $a : $b } grep { !$_->{visited} } map { @$_ } @grid;

    $item->{visited} = 1; 
    my $x = $item->{pos}[0];
    my $y = $item->{pos}[1];

    for my $pos ( [ $x-1, $y], [$x+1,$y], [$x,$y-1], [$x, $y+1] ) {
        # Out of bounds
        next if $pos->[0] < 0
             || $pos->[0] > $max_x
             || $pos->[1] < 0
             || $pos->[1] > $max_y;

        my $neighbor = $grid[ $pos->[0] ][ $pos->[1] ];

        next if $neighbor->{heigth} > $item->{heigth} + 1;

        $neighbor->{steps} = $item->{steps} < $neighbor->{steps} ? $item->{steps} + 1 : $neighbor->{steps};
    }

    last if $item->{end};
}

say "Task: " . $item->{steps} . " steps";
