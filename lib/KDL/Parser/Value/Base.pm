package KDL::Parser::Value::Base;

use 5.01800;
use strict;
use warnings;
no warnings "experimental::regex_sets";

use Carp;
use KDL::Parser::Error qw(parse_error);
use KDL::Parser::Util qw(unescape_string escape_string format_identifier);

sub _get_grammar {
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
  my $integer = qr/([-+])?[0-9][0-9_]*/;
  my $exponent = qr/(E|e)(?<epart>$integer)/;
  my $decimal = qr/(?<wpart>$integer)((?<dpoint>\.)(?<dpart>[0-9][0-9_]*))?$exponent?/;
  my $number = qr/($decimal|$hex|$octal|$binary)/;
  return +{
    unicode_space => qr/\h/,
    bom => qr/\N{U+FEFF}/,
    identifier => qr{($string|$bare_identifier)},
    value => qr{($string|$number|$keyword)},
    raw_string => $raw_string,
    escaped_string => $escaped_string,
    bare_identifier => $bare_identifier,
    escape => $escape,
    string => $string,
    number => $number,
    decimal => $decimal,
    keyword => $keyword,
  };
}

sub new {
  my $class = shift;
  my %kwargs = @_;
  my %self = (
    'fragment' => '', # the actual string parsed from the document
    'tag' => '', # the type annotation, if any
    'value' => '', # the parsed value
    'annotated' => 0, # flag to set to 1 if the value has an explicit type annotation
  );

  while (my ($key, $value) = each %kwargs) {
    if (exists $self{$key} && defined $value) {
      $self{$key} = $value;
    }
  }
  my $self = bless \%self, $class;

  if (!$self{value}) {
    my ($type, $value) = $self->parse($self{fragment}, $self{tag});
    $self{type} = $type;
    $self{value} = $value;
  }

  return $self;
}

sub to_kdl {
  my ($self, $config) = @_;
  my $out = '';
  if ($self->{annotated}) {
    my $tag = format_identifier($self->{tag});
    $out .= "($tag)";
  }
  $out .= $self->format($config);
  return $out;
}

sub format {
  my ($self, $config) = @_;
  croak "format not implemented";
}

sub parse {
  my $class = shift;
  my ($value, $tag) = @_;
  parse_error("parse not implemented");
}

sub error {
  my ($self, $msg) = @_;
  parse_error($msg);
}

1;
