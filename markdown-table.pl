#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use feature 'say';

binmode(STDOUT,":utf8");
binmode(STDIN ,":utf8");
binmode(STDERR,":utf8");

package Actions;
use PandocTable;

sub new {
	my ($class,$self)=(shift,{@_});
	bless($self,$class);
	return $self;
}

sub usage {
	say "USAGE: $0 [ yaml | csv | tsv | direct ]";
	return 255;
}

sub yaml {
	shift;
	say PandocTable->new(shift)->parse->yaml;
}

sub direct {
	shift;
	say PandocTable->new(shift)->direct->yaml;
}

sub csv {
	shift;
	say PandocTable->new(shift)->parse->spv(",");
}

sub tsv {
	shift;
	say PandocTable->new(shift)->parse->spv("\t");
}

package Main;

my $actions=Actions->new();

my $buf=""; { local $/; $buf=<STDIN> };
my $cmd=$ARGV[0] || '';

if($actions->can($cmd)) { $actions->$cmd($buf) } else { $actions->usage }

1;
