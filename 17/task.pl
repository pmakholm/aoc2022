#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

my @shapes = (
    [ [0,0], [1,0], [2,0], [3,0] ],
    [ [0,1], [1,2], [1,1], [1,0], [2,1] ],
    [ [0,0], [1,0], [2,0], [2,1], [2,2] ],
    [ [0,0], [0,1], [0,2], [0,3] ],
    [ [0,0], [1,0], [0,1], [1,1] ]
);

my @heigth = (1,3,3,4,2);

my @grid;

sub free($corner, $shape, $grid) {
    for my $point (@{ $shapes[$shape % scalar(@shapes)] }) {
        my $x = $corner->[0] + $point->[0];
        my $y = $corner->[1] + $point->[1];

        # Out of bounds
        return if $x < 0;
        return if $x > 6;
        return if $y < 0;

        # Occupied
        return if $grid->[$x][$y];
    }

    return 1;
}

sub freeze($corner, $shape, $grid) {
    for my $point (@{ $shapes[$shape % scalar(@shapes)] }) {
        my $x = $corner->[0] + $point->[0];
        my $y = $corner->[1] + $point->[1];

        $grid->[$x][$y] = 1;
    }
}

sub step($corner, $direction) {
    return [ $corner->[0] - 1, $corner->[1] ] if $direction eq '<';
    return [ $corner->[0] + 1, $corner->[1] ] if $direction eq '>';
    return [ $corner->[0], $corner->[1] - 1 ] if $direction eq 'v';
    return $corner;
}

sub draw($heigth, $grid, $corner=undef, $shape=undef) {
    my $stone = [];
    freeze($corner, $shape, $stone) if defined $corner;
    do {
        say "|", join('', map { $stone->[$_][$heigth] ? "@" : $grid->[$_][$heigth] ? "#" : "." } (0..6)), "|";
    } while($heigth--);
    say "+-------+"
}

my $directions = <>;
chomp $directions;
my $step = 0;
my $shape = 0;

my $grid = [];
my $heigth = 0;

my $corner = [ 2, $heigth + 3 ];

my @seen;
my %seen;

while (1) {
    my $dir = substr($directions, $step % length($directions), 1);
    #say $dir;
    if (free(step($corner, $dir),$shape, $grid)) {
        $corner = step($corner, $dir);
    }

    if (free(step($corner, 'v'), $shape, $grid)) {
        $corner = step($corner, 'v');
    } else {
        freeze($corner, $shape, $grid);       
        
        if ($shape % scalar(@shapes) == 0) {
            #say "$shape frozen at direction ", $step % length($directions), " at heigth $heigth";
        }

        my $top = $corner->[1] + $heigth[$shape % scalar(@shapes)];
        $heigth = $heigth > $top ? $heigth : $top;

        $shape++;
        $corner = [ 2, $heigth + 3 ];

        say "Task 1: $heigth" if $shape == 2022;
        say "Input for task 2: $heigth" if $shape == 3600;
        last if $shape == 1_000_000_000_000;
    }

    $step++
}

# My original subimission of task 2 involved some pen and paper work.
#
#   Looking at the index into directions each '-' shaped lands at, we see a
#   1700 shapes cycle starting at shape 1695. Each cycle have a heigth of 2654 rows.
#
#   So, the result is the heigth(at shape 1695) plus int(10^12/1700)*2654 + height(205 shapes of a cycle)
#
#   At some time I might revisit to calculate this programatically
