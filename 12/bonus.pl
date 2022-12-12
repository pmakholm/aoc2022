#!/usr/bin/perl

use v5.34;
use experimental 'signatures';

# This bonus solution actually uses a priority queue. For the given
# input, this gives a factor 10 speed-up. But I think this changes
# the solution from something like O(n^2 log n) to O(n log n)

use List::MoreUtils qw(first_index);

my $INT_MAX = 99999;

########################################################################
#
# Simple priority queue
#
########################################################################

sub Q::new($class) {
    return bless {}, $class;
}

sub Q::priority($this, $item) {
    return $item->{steps} + $item->{distance};
}

sub Q::enqueue($this, $item) {
    push @{ $this->{ $this->priority($item) } }, $item;
}

sub Q::update($this, $item, $new) {
    my $old = $this->priority($item);

    my $index = first_index { $_ == $item } @{ $this->{$old} };
    splice @{ $this->{$old} }, $index, 1;

    $item->{steps} = $new;

    push @{ $this->{ $this->priority($item) } }, $item;
}

sub Q::dequeue($this) {
    # Pop from priority queue
    my $priority = 0;
    while (1) {
        last if $priority > $INT_MAX * 2;
        unless (exists $this->{$priority}) {
            $priority++;
            next;
        }
        
        my $item = shift @{ $this->{$priority} };
        delete $this->{$priority} if scalar(@{ $this->{$priority} }) == 0;
        return $item;
    }
}

########################################################################
#
# Input parsing
#
########################################################################

sub new($x,$y,$mark, $start, $store) {
    my $heigth = ord($mark);

    # Special casing start and end
    $heigth = ord('a') if $mark eq 'S';
    $heigth = ord('z') if $mark eq 'E';
    
    my $node = {
        pos => [ $x, $y ],
        neighbors => [],
        heigth => $heigth,
        steps => $mark eq $start ? 0 : $INT_MAX,
        distance => $INT_MAX,
        end => $mark eq 'E',
    };

    $store->($node) if $node->{end};

    return $node;
}

sub parse($start, @input) {
    my $queue = Q->new();

    my @grid;
    my $x = 0;

    my $end;

    for (@input) {
        my $y = 0;
        my @line = map { new($x, $y++, $_, $start, sub($item) { $end = $item }) } split //;

        push @grid, \@line;
        $x++;
    }

    # Create edges for each possible step, and add it to priority queue
    my $max_x = $#grid;
    my $max_y = $#{ $grid[0] };

    for my $item (map {@$_ } @grid) {
        my $x = $item->{pos}[0];
        my $y = $item->{pos}[1];

        for my $pos ( [ $x-1, $y], [$x+1,$y], [$x,$y-1], [$x, $y+1] ) {
            # Out of bounds
            next if $pos->[0] < 0
            || $pos->[0] > $max_x
            || $pos->[1] < 0
            || $pos->[1] > $max_y;

            my $neighbor = $grid[ $pos->[0] ][ $pos->[1] ];

            next if $neighbor->{heigth} > $item->{heigth} + 1;

            push @{ $item->{neighbors} }, $neighbor;
        }

        $item->{distance} = 
            abs( $item->{pos}->[0] - $end->{pos}->[0] ) + 
            abs( $item->{pos}->[1] - $end->{pos}->[1] );

        $queue->enqueue($item);
    }

    return $queue;
}


########################################################################
#
# Do the Dijkstra dance...
#
########################################################################

sub dijkstra($queue) {
    my $item;
    while (1) {
        $item = $queue->dequeue();
        last if $item->{end};

        $item->{visited} = 1;

        for my $neighbor (@{ $item->{neighbors} }) {
            next if $neighbor->{visited};
            next if $neighbor->{steps} <= $item->{steps};

            $queue->update($neighbor, $item->{steps} + 1);
        }
    }

    return $item;
}

########################################################################
#
# And finally doing each task
#
########################################################################

my @input = <>;
chomp for @input;

say "Task 1: " . dijkstra(parse('S', @input))->{steps} . " steps";
say "Task 2: " . dijkstra(parse('a', @input))->{steps} . " steps";
