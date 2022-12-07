#!/usr/bin/perl

use v5.34;

my @path;
my %size;

$/ = "\n";
while (<>) {
    if (/\$ cd \.\./) {
        pop @path;

        next;
    }

    if (/\$ cd \//) {
        @path = ('/');

        next;
    }

    if (/\$ cd (.*)/) {
        push @path, "$path[-1]/$1";

        next;
    }

    if (/\$ .*/) {
        next;
    }

    if (/(\d+) (.*)/) {
        $size{$_} += $1 for @path;
    }
}

my $sum;
my $target = 30000000 - ( 70000000 - $size{'/'} );
my $smallest = $size{'/'};
for (values %size) {
    $sum += $_ if $_ <= 100000;
    $smallest = $_ if ($_ >= $target && $_ < $smallest);
}

say "Task 1: ", $sum;
say "Task 2: ", $smallest;

