#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

## Parsing
my @monkey;
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
    }

    if (/^\s*If (\w+): throw to monkey (\d+)/) {
        $monkey[-1]->{$1} = $2;
    }
}

# Round
for (1..20) {
    for my $id (0..$#monkey) { 
        say "Monkey $id";
        while (@{ $monkey[$id]->{items} }) {
            my $item = shift @{ $monkey[$id]->{items} };
            say "  Monkey inspects an item with a morry level of $item";

            $item = $monkey[$id]->{operation}->( $item );
            say "    Worry level changed to $item";

            $item = int( $item / 3 );
            say "    Monkey gets bored. Worry level changed to $item";

            my $target = $monkey[$id]->{ $item % $monkey[$id]->{divisor} ? "false" : "true" };
            say "    Item is thrown to monkey $target";

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
