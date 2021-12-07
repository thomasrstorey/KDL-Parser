package KDL::Parser;
use 5.018000;
use strict;
use warnings;
no warnings "experimental::regex_sets";

our $VERSION = "0.01";

use Carp;
use Data::Dumper;
use KDL::Parser::Document;
use KDL::Parser::Node;
use KDL::Parser::Value;
use KDL::Parser::Error qw(parse_error);
use KDL::Parser::Util qw(unescape_string);

my $verbose = 1;

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

  open my $kdl_fh, '<:encoding(UTF-8)', $filepath or croak($!);
  my $kdl_src = do { local $/ = undef; <$kdl_fh> };
  $self->parse($kdl_src);
}

sub _get_grammar {
  # TODO: For some reason this is capturing open paren "(" characters??
  # Either the interpolation is not working as expected or the range is wrong or one
  # of these unicode characters is, unexpectedly, an open paren???
  my $newline = '\n\r\N{U+000a}-\N{U+00d}\N{U+0085}\N{U+2028}\N{U+2029}';
  my $unicode_space = qr/\h/;
  my $bom = qr/\N{U+FEFF}/;
  my $single_line_comment = qr{//[^$newline]*};
  my $multi_line_comment = qr{/\*([^*/]|\*(?!/)|(?<!\*)/)*\*/};
  my $whitespace = qr{($bom|$unicode_space|($multi_line_comment))};
  my $linespace = qr{(\r\n|\n\r|(?<newline>[$newline])|$whitespace|$single_line_comment)};

  my $boolean = qr/(true|false)/;
  my $keyword = qr/(true|false|null)/;
  my $hex_digit = qr/[0-9a-fA-F]/;
  my $escape = qr{(["\\/bfnrt]|u\{$hex_digit{1,6}\})};
  my $character = qr{(\\$escape|[^\"])};
  my $escaped_string = qr{"(?<escaped>$character*)"};
  my $raw_string_hash = qr/(#*)"(?<raw>.*)"\1/;
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
  my $number = qr/($hex|$octal|$binary|$decimal)/;
  my $integer_types = qr/([iu](8|16|32|64|size))/;
  my $float_types = qr/(f(32|64)|decimal(64|128))/;
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
    value => qr{($string|$number|$keyword)},
    raw_string => $raw_string,
    escaped_string => $escaped_string,
    bare_identifier => $bare_identifier,
    escape => $escape,
    string => $string,
    number => $number,
    keyword => $keyword,
    integer_types => $integer_types,
    float_types => $float_types,
    numeric_types => qr{($integer_types|$float_types)}
  };
}

sub _parse_linespace {
  my $self = shift;
  if (/\G$self->{grammar}->{linespace}+/mgc) {
    return 1;
  }
  return 0;
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
    my ($key, $value) = $self->_parse_node_prop_or_arg();
    if ($key) {
      $node_props{$key} = $value;
    } elsif ($value) {
      push @node_args, $value;
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
    return 0;
  }

  $self->_parse_nodespace();

  return 1;
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
  if(/\G\(($self->{grammar}->{identifier})\)/mgc) {
    my $type_annotation = $1;
    return $type_annotation;
  }

  return 0;
}

sub _parse_node_prop_or_arg {
  my $self = shift;
  # TODO: This fails in the case of slashdash before children but after
  # all args and props. The slashdash is consumed before it can be considered
  # in the context of the node children.
  my $is_sd = $self->_parse_slashdash();
  if (/\G
      (?<key>$self->{grammar}->{identifier})
      =
      (\((?<type>$self->{grammar}->{identifier})\))?
      (?<value>$self->{grammar}->{value})/xmgc and !$is_sd)
  {
    my $type = $self->_parse_ident($+{type});

    return (
      $self->_parse_ident($+{key}),
      KDL::Parser::Value->new((
          kdl_data => $+{value},
          type => $type,
          annotated => (not (not $+{type}))
        ))
    );
  } elsif (/\G
      (\((?<type>$self->{grammar}->{identifier})\))?
      (?<value>$self->{grammar}->{value})/xmgc and !$is_sd)
  {
    my $type = $self->_parse_ident($+{type});
    return (
      0,
      KDL::Parser::Value->new((
          kdl_data => $+{value},
          type => $type,
          annotated => (not (not $+{type}))
        ))
    );
  }
  return (0, 0);
}

sub _parse_ident {
  my ($self, $str) = @_;
  return 0 unless $str;
  # $str may be a raw string r##"..."## escaped string "..." or bare identifier.
  if ($str =~ /^$self->{grammar}->{raw_string}$/) {
    return $+{raw};
  } elsif ($str =~ /^$self->{grammar}->{escaped_string}$/) {
    my $esc = $+{escaped};
    return unescape_string($esc);
  } elsif ($str =~ /^$self->{grammar}->{bare_identifier}$/) {
    return $str;
  }
  parse_error("Malformed identifier.");
}

sub _parse_value {
  my ($self, $value, $type) = @_;

  if ($value =~ /$self->{grammar}->{string}/i) {
    if (defined $type && $type =~ /$self->{grammar}->{numeric_types}/) {
      parse_error("Non-numeric value annotated with reserved numeric type ($type).");
    }
    # TODO: Validate and interpret value with type if provided
    if (defined $+{raw}) {
      return $+{raw};
    } elsif (defined $+{escaped}) {
      return $self->_unescape_string($+{unescaped});
    }
  } elsif ($value =~ /$self->{grammar}->{number}/) {
    if (defined $type && $type =~ /$self->{grammar}->{string_types}/) {
      parse_error("Numeric value annotated with reserved string type ($type).");
    }
    # TODO: Validate and interpret value with type if provided
    my $sign = $value =~ /^[-+]/;
    my $numeric_value = 0;
    if ($sign) {
      $value =~ s/^[-+]//;
    }
    if ($value =~ /x/) {
      $numeric_value = hex($value);
    } elsif ($value =~ /o/) {
      $numeric_value = oct($value);
    } elsif ($value =~ /b/) {
      my @bitstring = split("b", $value);
      my $bitstring = $bitstring[1];
      my $bslen = length($bitstring);
      for (my $l = 8; $l < 512; $l += 8) {
        if ($bslen < $l) {
          $bitstring = ('0' x ($l - $bslen)) . $bitstring;
          last;
        }
      }
      $numeric_value = ord(pack(length($bitstring), $bitstring));
    } else {
      $numeric_value = $value + 0;
    }
    if ($sign eq '-') {
      return -1 * $numeric_value;
    }
    return $numeric_value;
  } elsif ($value =~ /$self->{grammar}->{keyword}/) {
    if ($value eq 'true') {
      return 1;
    } elsif ($value eq 'false') {
      return 0;
    } elsif ($value eq 'null') {
      return undef;
    }
  }
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
    parse_error("Unexpected end of file before node child list terminator.");
  } elsif (!/\G\}/mgc) {
    my $char = substr $_, pos(), 1;
    parse_error("Unexpected character $char at end of node child list.");
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
  parse_error("Unexpected character $char before node terminator.");
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
