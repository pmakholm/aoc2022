#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

use constant LENGTH => 4;

sub valid($marker) {
    my %set;
    $set{$_} = 1 for split //, $marker;

    return keys(%set) == LENGTH;
}

my $total = 0;
while (<>) {
    chomp;
    my $signal = $_;

    for (0..length($signal)) {
        if (valid(substr($signal, $_, LENGTH))) {
            $total += $_+LENGTH;
            last;
        }
    }
}

say $total;
