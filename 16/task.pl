#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

use List::Util qw(max sum);

my @input = map { s/\s*$//r } <>;

sub parse($line) {
    /Valve (\w\w) has flow rate=(\d*); tunnels? leads? to valves? (.*)/;
    return $1 => { flow => $2, next => [ split /, /, $3 ] };
}

sub steps($state, $actor, $cave) {
    my @steps;
    my $valve = $state->{$actor}->{valve};
    
    if ($cave->{$valve}{flow} > 0 && !$state->{open}{$valve}) {
        push @steps, {
            %$state,
            $actor => {
                valve => $valve, 
                seen => { $valve => 1 }
             },
            open => { %{ $state->{open} }, $valve => 1 },
            release => $state->{release} + $cave->{$valve}{flow},
        };
    }

    for my $next (@{ $cave->{$valve}{next} }) {
        next if $state->{seen}{$next};

        push @steps, { 
            %$state,
            $actor => {
                valve => $next,
                seen => { %{ $state->{$actor}{seen} }, $next => 1 },
            },
            open => $state->{open},
            release => $state->{release},
        }
    }

    return @steps;
}

sub pseudostep($state, $actor, $cave) {
    return $state if scalar( keys %{ $state->{open} } ) == scalar( keys %$cave );

    my $valve = $state->{$actor}->{valve};
    if ($state->{open}{ $valve }) {
        my ($new) = sort { $cave->{$b}{flow} <=> $cave->{$a}{flow} }
                    grep { !$state->{seen}{$_} }
                    grep { $_ ne $state->{me}{valve} }
                    grep { $_ ne $state->{elephant}{valve} }
                    keys %$cave;

        return {
            %$state,
            $actor => {
                valve => $new
            }
        };
    }

    return {
        %$state,
        open => { %{ $state->{open} }, $valve => 1 },
        release => $state->{release} + $cave->{$valve}{flow},
    }
}

sub flow($state) {
    return {
        %$state,
        total => $state->{total} + $state->{release}
    }
}

sub hash($state, @actors) {
    my @open = sort keys %{ $state->{open} };
    my @locations = sort map { $state->{$_}->{valve} } @actors;

    return join "|", @locations, @open;
}

my %cave = map { parse($_) } @input;
my $full = sum map { $_->{flow} } values %cave;

my @state = ({
    "me" => {
        valve => "AA",
        seen => { "AA" => 1 },
    },
    open => { },
    release => 0,
    total => 0
});

for (1..29) {
    my %seen;
    @state = grep { !$seen{ hash($_, "me")}++}
             sort { $b->{total} <=> $a->{total} }
             map { flow($_) }
             map { steps($_, "me", \%cave) } @state;
}

say "Task 1: " . max map { $_->{total} } @state;

@state = ({
    "me" => {
        valve => "AA",
        seen => { "AA" => 1 },
    },
    "elephant" => {
        valve => "AA",
        seen => { "AA" => 1 },
    },
    open => { },
    release => 0,
    total => 0
});

for (1..25) {
    my %seen;
    @state = grep { !$seen{ hash($_, "me", "elephant")}++}
             sort { $b->{total} <=> $a->{total} }
             map { flow($_) }
             map { steps($_, "elephant", \%cave) }
             map { steps($_, "me", \%cave) }
             @state;

    # This is probably cheating...
    if (@state > 10000) {
        @state = @state[0..10000];
    }
}

say "Task 2: " . max map { $_->{total} } @state;



