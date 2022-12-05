#!/usr/bin/perl

use v5.34;

# Make one copy of the stacks for each task
my @task1;
my @task2;

while (<>) {
    last if /^\s*1/;

    for my $i (1..9) {
        my $offset = (4 * $i) - 3;
        my $crate  = substr $_, $offset, 1;

        next unless $crate =~ /[A-Z]/;
	
        $task1[$i] //= [];
        unshift @{ $task1[$i] }, $crate;

        $task2[$i] //= [];
        unshift @{ $task2[$i] }, $crate;
    }
}

# Handle move operations
while (<>) {
    /move (\d+) from (\d) to (\d)/ or next;

    my $count = $1;
    my $src = $2;
    my $dst = $3;

    # Crane 9000
    for (1..$count) {
        my $crate = pop @{ $task1[$src] };
        push @{ $task1[$dst] }, $crate;
    }

    # Crane 9001
    my @crates = splice @{ $task2[$src] }, -$count;
    push @{ $task2[$dst] }, @crates;
} 

my $top1;
$top1 .= $task1[$_][-1] for (1..9);

my $top2;
$top2 .= $task2[$_][-1] for (1..9);

say "Task 1: $top1";
say "Task 2: $top2";
