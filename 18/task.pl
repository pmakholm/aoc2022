#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

my @input = map { s/\s*$//r } <>;
my %grid  = map { $_ => 1 } @input;

my $count = 0;
$; = ",";
for (keys %grid) {
    my ($x,$y,$z) = split /,/;

    $count++ unless $grid{$x+1,$y,$z};
    $count++ unless $grid{$x-1,$y,$z};
    $count++ unless $grid{$x,$y+1,$z};
    $count++ unless $grid{$x,$y-1,$z};
    $count++ unless $grid{$x,$y,$z+1};
    $count++ unless $grid{$x,$y,$z-1};
}

say "Task 1: $count";

my %outside;
my @work = [30,30,30];
while (@work) {
    my ($x, $y, $z) = @{ shift @work };

    next if $outside{ $x, $y, $z };

    $outside{ $x, $y, $z } = 1;

    push @work, [ $x+1, $y, $z ] unless $x > 30  || $grid{$x+1,$y,$z} || $outside{$x+1,$y,$z};
    push @work, [ $x-1, $y, $z ] unless $x < -30 || $grid{$x-1,$y,$z} || $outside{$x-1,$y,$z};
    push @work, [ $x, $y+1, $z ] unless $y > 30  || $grid{$x,$y+1,$z} || $outside{$x,$y+1,$z};
    push @work, [ $x, $y-1, $z ] unless $y < -30 || $grid{$x,$y-1,$z} || $outside{$x,$y-1,$z};
    push @work, [ $x, $y, $z+1 ] unless $z > 30  || $grid{$x,$y,$z+1} || $outside{$x,$y,$z+1};
    push @work, [ $x, $y, $z-1 ] unless $z < -30 || $grid{$x,$y,$z-1} || $outside{$x,$y,$z-1};
}

my $count = 0;
for (keys %grid) {
    my ($x, $y, $z) = split /,/;

    $count++ if $outside{$x+1,$y,$z};
    $count++ if $outside{$x-1,$y,$z};
    $count++ if $outside{$x,$y+1,$z};
    $count++ if $outside{$x,$y-1,$z};
    $count++ if $outside{$x,$y,$z+1};
    $count++ if $outside{$x,$y,$z-1};
}

say "Task 2: $count";


