#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

use List::Util qw(reduce);
use List::MoreUtils qw(indexes natatime);
use JSON;

sub valid($left, $right) {
    if (not (ref $left || ref $right)) {
        return if $left == $right;
        return $left < $right;
    }

    if (not ref $left) {
        $left = [ $left ];
    }

    if (not ref $right) {
        $right = [ $right ];
    }

    if (@$left == 0) {
        if (@$right == 0) {
            # Both lists are empty. Result is undecided
            return;
        }

        return 1;
    }

    if (@$right == 0) {
        return 0;
    }

    return valid(shift @$left, shift @$right) // valid($left, $right);
}

my $total;
my $index = 0;
my @input = <>;

# Task 1: 
my $it = natatime 3, @input;
while(my @vals = $it->()) {
    my $left = decode_json $vals[0];
    my $right = decode_json $vals[1];

    $index++;

    $total += $index if valid($left, $right);
}

say "Task 1: $total";

# Task 2:

# Using json to clone and inspect data clearly says:
#  - I've got a hammer and I'm not afraid of using it.

sub clone($data) {
    return decode_json(encode_json($data));
}

sub divider($data) {
    my $json = encode_json($data);

    return $json eq '[[2]]' || $json eq '[[6]]';
}

my $total = reduce { $a * $b } 
            map { $_ + 1 }
            indexes { divider($_) } 
            sort { valid(clone($a),clone($b)) ? -1 : 1 }
            map { decode_json $_ }
            grep {!/^$/}
            @input, "[[2]]", "[[6]]";

say "Task 2: $total";
