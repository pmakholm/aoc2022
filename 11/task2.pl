#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

## Parsing
my @monkey;
my $mod = 1;
while (<>) {
    chomp;

    if (/^Monkey/) {
        push @monkey, { actions => 0 };
    }

    if (/^\s*Starting items: (.*)/) {
        $monkey[-1]->{items} = [ split /, /, $1 ];
    }

    if (/^\s*Operation: (.*)/) {
        my $operation = $1;
        $operation =~ s/(new|old)/\$$1/g;

        $monkey[-1]->{operation} = eval 'sub ($old) { my ' . $operation .'; return $new }';
    }

    if (/^\s*Test: divisible by (\d+)/) {
        $monkey[-1]->{divisor} = $1;
        $mod *= $1;
    }

    if (/^\s*If (\w+): throw to monkey (\d+)/) {
        $monkey[-1]->{$1} = $2;
    }
}

# Round
for my $round (1..10000) {
    for my $id (0..$#monkey) { 
        while (@{ $monkey[$id]->{items} }) {
            my $item = shift @{ $monkey[$id]->{items} };

            $item = $monkey[$id]->{operation}->( $item ) % $mod;

            my $target = $monkey[$id]->{ $item % $monkey[$id]->{divisor} ? "false" : "true" };
            push @{ $monkey[$target]->{items} }, $item;

            $monkey[$id]->{actions}++;
        }
    }
}

my @actions;
for my $id (0..$#monkey) {
    say "Monkey $id inspected items " . $monkey[$id]->{actions} . " times. ";
    push @actions, $monkey[$id]->{actions};
}

@actions = sort { $a <=> $b } @actions;

say "Monkey business: " . $actions[-1] * $actions[-2];
