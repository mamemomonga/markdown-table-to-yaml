package PandocTable;
use utf8;
use strict;
use warnings;
use feature 'say';

use JSON::XS;
use YAML::XS;
use constant DEBUG=>0;

sub new {
	my ($class,$ast)=@_;
	my $self={};
	bless($self,$class);

	utf8::encode($ast);
	$self->{ast}=JSON::XS->new()->utf8->decode($ast);

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

sub direct {
	my $self=shift;
	$self->{data}=$self->{ast};
	return $self;
}

sub spv {
	my ($self,$delimiter)=@_;
	
	foreach my $datas(@{$self->{data}}) {
		my @lines=( join($delimiter,map {qq{"$_"}} @{$datas->{fields}}));
		foreach my $row(@{$datas->{rows}}) {
			push @lines,join($delimiter,map {qq{"$_"}} @{$row});
		}
		say join("\n",@lines);
		say "";
	}
}


sub parse_str {
	my ($self,$in)=@_;
	my @str=();

	my $recu;
	$recu=sub {
		my $ref=shift;
		if(ref($ref) eq 'ARRAY') {
			foreach(@{$ref}) { &{$recu}($_) }
		} elsif (ref($ref) eq 'HASH') {
			if($ref->{t} eq 'Str') {
				push @str,$ref->{c};

			} elsif ($ref->{t} eq 'Space') {
				push @str,' ';

			} else {
				&{$recu}($ref->{c});
			}

		}
	};
	&{$recu}($in);
	return join('',@str);
}


sub parse {
	my $self=shift;

	my @datas=();
	my $nest=0; my @line=(); my @lines=(); my @fields=();

	my $recu;
	$recu=sub {
		my $ref=shift;

		if(ref($ref) eq 'ARRAY') {
			$nest++;

			if($nest == 5) {
				push @lines,[@line] if($#line != -1);
				@line=();
			}

			say $nest if(DEBUG);
			foreach(@{$ref}) { &{$recu}($_) }
			$nest--;
	
	
		} elsif(ref($ref) eq 'HASH') {
			return unless $ref;
			return unless $ref->{t};

			if($ref->{t} eq 'Plain') {
				say "$nest:Plain" if (DEBUG);
				my $str=$self->parse_str($ref->{c});
				say "  [$str]" if (DEBUG);
				push @fields,$str if ($nest == 5);
				push @line,$str   if ($nest == 6);

	
			} elsif($ref->{t} eq 'Table') {
				say "$nest:Table" if (DEBUG);
				&{$recu}($ref->{c});

				push @lines,[@line] if($#line != -1);
				push @datas,{fields=>[@fields],rows=>[@lines]};

				@line=(); @lines=(); @fields=();

			}
		}
	};
	&{$recu}( $self->{ast} );
	$self->{data}=\@datas;
	return $self;
}

sub Dumper {
	eval {
		no warnings;
		require 'Data/Dumper.pm';
		*Data::Dumper::qquote=sub{return shift};
		local $Data::Dumper::Useperl=1;
		my $d=Data::Dumper->new(\@_)->Dump;
		return $d;
	};
}

1

