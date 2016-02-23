#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use feature 'say';

binmode(STDOUT,":utf8");
binmode(STDIN ,":utf8");
binmode(STDERR,":utf8");

package PandocTable;

use JSON::XS;
use YAML::XS;

use constant DEBUG=>0;

sub new {
	my ($class,$ast)=@_;
	my $self={};
	bless($self,$class);
	$self->{ast}=$ast;
	return $self;
}

sub data {
	my $self=shift;
	return $self->{data};
}

sub yaml {
	my $self=shift;
	my $buf=YAML::XS::Dump($self->{data});
	utf8::decode($buf);
	return $buf;
}

sub parse {
	my $self=shift;

	my @datas=();

	my $nest=0;
	my @line=();
	my @lines=();
	my @fields=();

	my $decode;
	$decode=sub {
		my $ref=shift;

		if(ref($ref) eq 'ARRAY') {
			$nest++;

			if($nest == 5) {
				push @lines,[@line] if($#line != -1);
				@line=();
			}

			say $nest if(DEBUG);
			foreach(@{$ref}) { &{$decode}($_) }
			$nest--;
	
	
		} elsif(ref($ref) eq 'HASH') {
			return unless $ref;
			return unless $ref->{t};

			if($ref->{t} eq 'Str') {

				push @line,$ref->{c}   if ($nest == 7);
				push @fields,$ref->{c} if ($nest == 6);

				say "$nest:".Dumper($ref->{c}) if(DEBUG);


			} elsif($ref->{t} eq 'Plain') {
				&{$decode}($ref->{c});
	
			} elsif($ref->{t} eq 'Table') {
				&{$decode}($ref->{c});
				say "TABLE" if(DEBUG);

				push @lines,[@line] if($#line != -1);
				push @datas,{fields=>[@fields],rows=>[@lines]};

				@line=();
				@lines=();
				@fields=();

			}
		}
	};

	my $ast=$self->{ast}; utf8::encode($ast);
	&{$decode}( JSON::XS->new()->utf8->decode($ast) );

	$self->{data}=\@datas;
	return $self;
}

package Main;

my $buf=""; { local $/; $buf=<> };
say PandocTable->new($buf)->parse->yaml;


1;
