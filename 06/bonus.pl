#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

use re 'eval';

#
# First thought of part 1: I can do this with regular expressions.
#
# But I'm glad I didn't follow that thought. Part 2 would have been a mess,
# but after submitting my solutions I still thought about regular expressions.
#
# This was my first attempt at part 1:
# $ perl -nlE '/(.)(?!\1)(.)(?!\1|\2)(.)(?!\1|\2|\3)(.)/g && say pos($_)' input.txt
#
# It works, but isn't very extendable...
#
# After a while I came up with a more generic solution. Originally a
# one-liner, but expanded for the sake of readability:
#

sub boundary($length, $message) {
    my $re = q<((??{ join "","[^",@{^CAPTURE},"]" }))> x ($length-1);

    $message =~ /(.)$re/g;

    return pos($message);
}

my $data = do { local $/ = undef; <> };

say "Task 1: ", boundary(4,$data);
say "Task 2: ", boundary(14,$data);

