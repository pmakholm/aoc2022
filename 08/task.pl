#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

use List::Util qw(any all reduce);
use List::MoreUtils qw(before_incl);

sub visible($x,$y,$grid, $x_max, $y_max) {
    my $target = $grid->[$x][$y];

    my $left = all { $_ < $target } map { $grid->[$_][$y] } 0..$x-1;
    my $right = all { $_ < $target } map { $grid->[$_][$y] } $x+1..$x_max;
    my $top = all { $_ < $target } map { $grid->[$x][$_] } 0 .. $y-1;
    my $bottom = all { $_ < $target } map { $grid->[$x][$_] } $y+1 .. $y_max;

    return any { $_ } $left, $right, $top, $bottom;
}

sub scenic($x, $y, $grid, $x_max, $y_max) {
    my $target = $grid->[$x][$y];

    my @left = reverse map { $grid->[$_][$y] } 0..$x-1;
    my @right = map { $grid->[$_][$y] } $x+1..$x_max;
    my @top = reverse map { $grid->[$x][$_] } 0 .. $y-1;
    my @bottom = map { $grid->[$x][$_] } $y+1 .. $y_max;

    # XXX before_incl has an odd behavior in scalar context, so I need
    # to explicitly force it to be evaluated in list context before coercing
    # it to scalar context. (Yeah, length of a list is spelled 'scalar')
    #
    # This odd behavior has been rapported as https://rt.cpan.org/Public/Bug/Display.html?id=145515

    return reduce { $a * $b }
           map { scalar (()= before_incl { ;$_ >= $target } @$_) } \@left, \@right, \@top, \@bottom;
}

my $grid;

while(<>) {
    chomp;
    push @$grid, [ split //, $_ ]
}

my $x_max = $#{ $grid };
my $y_max = $#{ $grid->[0] };

my $total;
my $best = 0;
for my $x (0..$x_max) {
    for my $y (0..$y_max) {
        $total++ if visible($x,$y,$grid,$x_max,$y_max);

        my $scenic = scenic($x,$y,$grid,$x_max,$y_max);
        $best = $best > $scenic ? $best : $scenic;
    }
}

say "Task 1: $total";
say "Task 2: $best";
