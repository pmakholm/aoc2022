#!env perl

use v5.34;

my %play = (
	AX => 0 + 3,
	AY => 3 + 1,
	AZ => 6 + 2,

	BX => 0 + 1,
	BY => 3 + 2,
	BZ => 6 + 3,

	CX => 0 + 2,
	CY => 3 + 3,
	CZ => 6 + 1,
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

