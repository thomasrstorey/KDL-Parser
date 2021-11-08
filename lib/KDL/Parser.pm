package KDL::Parser;
use 5.018000;
use strict;
use warnings;
no warnings "experimental::regex_sets";

use re 'strict';

our $VERSION = "0.01";

sub new {
  my $class = shift;
  return bless {grammar => $class->_get_grammar()}, $class;
}

sub parse {
  my ($self, $input) = @_;
  local $_ = $input;

  $self->_parse_linespace();

  my @document;
  until (/\G\z/mgc) {
    if (my $node = $self->_parse_node()) {
      push @document, $node;
    }
    $self->_parse_linespace();
  }

  return @document;
}

sub parse_file {
  my ($self, $filepath) = @_;

  open my $kdl_fh, '<:encoding(UTF-8)', $filepath or die $!;
  my $kdl_src = do { local $/ = undef; <$kdl_fh> };
  $self->parse($kdl_src);
}

sub _get_grammar {
  my $newline = qr/\n\r/;
  my $unicode_space = qr/\h/;
  my $bom = qr/\N{U+FEFF}/;
  my $single_line_comment = qr{//[^$newline]*};
  my $multi_line_comment = qr{/\*([^*/]|\*(?!/)|(?<!\*)/)*\*/};
  my $whitespace = qr{($bom|$unicode_space|($multi_line_comment))};
  my $linespace = qr{([$newline]|$whitespace|$single_line_comment)};

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
  return +{
    newline => qr/[$newline]/,
    unicode_space => qr/\h/,
    bom => qr/\N{U+FEFF}/,
    single_line_comment => $single_line_comment,
    multi_line_comment => $multi_line_comment,
    whitespace => $whitespace,
    linespace => $linespace,
    slashdash => qr{/-},
    identifier => qr{($string|$bare_identifier)}
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
  # TODO...
  return $name;
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
      break;
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

1;
__END__
