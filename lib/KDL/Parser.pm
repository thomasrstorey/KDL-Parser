package KDL::Parser;
use 5.018000;
use strict;
use warnings;
no warnings "experimental::regex_sets";

our $VERSION = "0.01";

use Data::Dumper;
use KDL::Parser::Document;
use KDL::Parser::Node;

my $verbose = 0;

sub new {
  my $class = shift;
  return bless {grammar => $class->_get_grammar()}, $class;
}

sub parse {
  my ($self, $input) = @_;
  local $_ = $input;

  $self->_parse_linespace();

  my $document = KDL::Parser::Document->new();
  until (/\G\z/mgc || (pos() || 0) >= length()) {
    if (my $node = $self->_parse_node()) {
      $document->push($node);
    }
    $self->_parse_linespace();
  }

  return $document;
}

sub parse_file {
  my ($self, $filepath) = @_;

  open my $kdl_fh, '<:encoding(UTF-8)', $filepath or die $!;
  my $kdl_src = do { local $/ = undef; <$kdl_fh> };
  $self->parse($kdl_src);
}

sub _get_grammar {
  my $newline = qr/\n\r\N{U+000a}-\N{U+00d}\N{U+0085}\N{U+2028}\N{U+2029}/;
  my $unicode_space = qr/\h/;
  my $bom = qr/\N{U+FEFF}/;
  my $single_line_comment = qr{//[^$newline]*};
  my $multi_line_comment = qr{/\*([^*/]|\*(?!/)|(?<!\*)/)*\*/};
  my $whitespace = qr{($bom|$unicode_space|($multi_line_comment))};
  my $linespace = qr{(\r\n|\n\r|[$newline]|$whitespace|$single_line_comment)};

  my $boolean = qr/(true|false)/;
  my $keyword = qr/(true|false|null)/;
  my $hex_digit = qr/[0-9a-fA-F]/;
  my $escape = qr{(["\\/bfnrt]|u\{$hex_digit{1,6}\})};
  my $character = qr{(\\$escape|[^\"])};
  my $escaped_string = qr{"($character*)"};
  my $raw_string_hash = qr/(#*)"(.*)"\1/;
  my $raw_string = qr/r$raw_string_hash/;
  my $string = qr{$raw_string|$escaped_string};
  my $identifier_char = qr/(?[ \S & [^\/(){}<>;\[\]=,"] ])/;
  my $bare_identifier = qr/
    (?!$keyword)
    (
      (?[ \S & [^\/(){}<>;\[\]=,"] & [^-+0-9] ])$identifier_char*
      |[-+](?[ \S & [^\/(){}<>;\[\]=,"] & [^0-9] ])$identifier_char*
    )
  /x;
  my $hex = qr/[-+]?0x$hex_digit($hex_digit|_)*/;
  my $octal = qr/[-+]?0o[0-7][0-7_]*/;
  my $binary = qr/[-+]?0b[01][01_]*/;
  my $integer = qr/[-+]?[0-9][0-9]*/;
  my $exponent = qr/(E|e)$integer/;
  my $decimal = qr/$integer(\.[0-9][0-9_]*)?$exponent?/;
  my $number = qr/($decimal|$hex|$octal|$binary)/;
  return +{
    newline => qr/(\r\n|\n\r|[$newline])/,
    unicode_space => qr/\h/,
    bom => qr/\N{U+FEFF}/,
    single_line_comment => $single_line_comment,
    multi_line_comment => $multi_line_comment,
    whitespace => $whitespace,
    linespace => $linespace,
    slashdash => qr{/-},
    identifier => qr{($string|$bare_identifier)},
    value => qr{($string|$number|$keyword)}
  };
}

sub _parse_linespace {
  my $self = shift;
  return /\G$self->{grammar}->{linespace}+/mgc;
}

sub _parse_node {
  my $self = shift;
  # slasdash prefixed?
  my $is_sd = $self->_parse_slashdash();
  # annotated?
  my $type_annotation = $self->_parse_type_annotation();

  # node name
  if (!/\G($self->{grammar}->{identifier})/mgc) {
    return 0;
  }
  my $name = $1;

  # props and args
  my %node_props;
  my @node_args;
  while (1) {
    if (!$self->_parse_nodespace()) {
      last;
    }
    my ($key, $type, $value) = $self->_parse_node_prop_or_arg();
    if ($key) {
      my @arg = ($type, $value);
      $node_props{$key} = \@arg;
    } elsif ($value) {
      push @node_args, ($type, $value);
    }
  }
  $self->_parse_nodespace();
  my @children = $self->_parse_node_children();
  $self->_parse_nodespace();
  $self->_parse_node_terminator();
  if ($is_sd) {
    return;
  }
  my %node_hash = (
    name => $name,
    type => $type_annotation,
    args => \@node_args,
    props => \%node_props,
    children => \@children,
  );
  my $node = KDL::Parser::Node->new(%node_hash);
  warn Dumper($node) if $verbose;
  return $node;
}

sub _parse_slashdash {
  my $self = shift;

  my $is_sd = /\G$self->{grammar}->{slashdash}/mgc;
  if (!$is_sd) {
    return $is_sd;
  }

  $self->_parse_nodespace();

  return $is_sd;
}

sub _parse_nodespace {
  my $self = shift;
  my $start = pos();
  while (1) {
    /\G$self->{grammar}->{whitespace}*/mgc;
    if (!$self->_parse_escline()) {
      last;
    }
  }
  return $start != pos();
}

sub _parse_escline {
  my $self = shift;
  if (!/\G\\/mgc) {
    return 0;
  }
  /\G$self->{grammar}->{whitespace}*/mgc;
  if (/\G$self->{grammar}->{newline}/mgc) {
    return 1;
  }
  return /\G$self->{grammar}->{single_line_comment}/mgc;
}

sub _parse_type_annotation {
  my $self = shift;

  /\G\(($self->{grammar}->{identifier})\)/mgc;
  my $type_annotation = $1;

  return $type_annotation;
}

sub _parse_node_prop_or_arg {
  my $self = shift;

  my $is_sd = $self->_parse_slashdash();
  if (/\G
      (?<key>$self->{grammar}->{identifier})
      =
      (\((?<type>$self->{grammar}->{identifier})\))?
      (?<value>$self->{grammar}->{value})/xmgc and !$is_sd)
  {
    return ($+{key}, $+{type}, $+{value});
  } elsif (/\G
      (\((?<type>$self->{grammar}->{identifier})\))?
      (?<value>$self->{grammar}->{value})/xmgc and !$is_sd)
  {
    return (0, $+{type}, $+{value});
  }
  return (0, 0, 0);
}

sub _parse_node_children {
  my $self = shift;
  my $is_sd = $self->_parse_slashdash();
  my @children;
  if (!/\G\{/mgc) {
    return @children;
  }
  while (1) {
    $self->_parse_linespace();
    my $child = $self->_parse_node();
    if ($child) {
      push @children, $child;
    } else {
      last;
    }
  }
  $self->_parse_linespace();

  if (/\G\z/mgc || pos() >= length()) {
    die "Unexpected end of file before node child list terminator.";
  } elsif (!/\G\}/mgc) {
    my $char = substr $_, pos(), 1;
    die "Unexpected character $char at end of node child list.";
  } elsif ($is_sd) {
    return [];
  }
  return @children;
}

sub _parse_node_terminator {
  my $self = shift;
  if (/\G($self->{grammar}->{newline}|;|\z)/mgc || pos() >= length() - 1) {
    return;
  }
  my $char = substr $_, pos(), 1;
  my ($lineno, $colno) = $self->_get_pos();
  die "Unexpected character \"$char\" before node terminator ($lineno,$colno).";
}

sub _get_pos {
  my $self = shift;
  my $line = 1;
  my $col = 1;
  for my $i (0..pos()) {
    my $char = substr($_, $i, 1);
    $col += 1;
    if ($char eq "\n") {
      $line += 1;
      $col = 1;
    }
  }
  return ($line, $col);
}

1;
__END__

=encoding utf-8

=head1 NAME

KDL::Parser - Perl implementation of a KDL parser.

=head1 SYNOPSIS

    use KDL::Parser;

    my $parser = KDL::Parser->new();
    my $document = $parser->parse_file('path/to/file.kdl');
    # document is an array of hashes which each represent a node
    for my $node (@document) {
      say $node->{name};
    }

=head1 DESCRIPTION

KDL::Parser is a Perl implementation of the KDL (pronounced like "cuddle") document language.
Learn more at L<https://github.com/kdl-org/kdl>.

=head1 LICENSE

Copyright (C) Thomas R Storey.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Thomas R Storey E<lt>orey.st@protonmail.comE<gt>
