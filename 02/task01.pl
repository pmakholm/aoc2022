#!env perl

use v5.34;

my %play = (
	AX => 3 + 1,
	AY => 6 + 2,
	AZ => 0 + 3,

	BX => 0 + 1,
	BY => 3 + 2,
	BZ => 6 + 3,

	CX => 6 + 1,
	CY => 0 + 2,
	CZ => 3 + 3,
);

my $i = 0;
my $point = 0;
while (<>) {
    s/\s//g;
    $i++;
    say "Round $i: Play $_ for $play{$_} points";
    $point += $play{$_};

}

say "Total: $point";

