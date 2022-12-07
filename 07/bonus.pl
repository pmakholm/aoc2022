#!/usr/bin/perl

use v5.34;

# On reflection I wondered how much of the hierarchy you need to handle.
#
# This versions minimizes the hierarchy, to a stack of buckets each
# containing the size.
#
# It assumes that the first command is 'cd /', but this assumption is
# easily avoided, by starting the id at 1 and adding id 0 to the stack
# from the start.

my @path;
my @size;
my $id = 0;

$/ = "\n";
while (<>) {
    if (/\$ cd \.\./) {
        pop @path;
        next;
    }

    if (/\$ cd (.*)/) {
        push @path, $id++;
    }

    if (/(\d+) (.*)/) {
        $size[$_] += $1 for @path;
    }
}

my $sum;
my $target = 30000000 - ( 70000000 - $size[0] );
my $smallest = $size[0];
for (@size) {
    $sum += $_ if $_ <= 100000;
    $smallest = $_ if ($_ >= $target && $_ < $smallest);
}

say "Task 1: ", $sum;
say "Task 2: ", $smallest;

