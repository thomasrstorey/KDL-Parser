package KDL::Parser::Value;

use 5.01800;
use strict;
use warnings;
no warnings "experimental::regex_sets";

use Carp;
use Math::BigFloat;
use Math::BigInt;
use KDL::Parser::Util qw(unescape_string escape_string format_identifier);
use KDL::Parser::Error qw(parse_error);
use Exporter 5.57 'import';
our @EXPORT_OK = qw/new/;

my $verbose = 0;

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
  my $integer_types = qr/([iu](8|16|32|64|size))/;
  my $float_types = qr/(f(32|64)|decimal(64|128))/;
  my $string_types = qr/(
    base64
    |country-2
    |country-3
    |country-subdivision
    |currency
    |date
    |date-time
    |decimal
    |duration
    |email
    |hostname
    |idn-email
    |idn-hostname
    |ipv4
    |ipv6
    |irl
    |irl-reference
    |regex
    |time
    |url
    |url-reference
    |url-template
    |uuid
    )/x;
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
    integer_types => $integer_types,
    float_types => $float_types,
    numeric_types => qr{($integer_types|$float_types)},
    string_types => $string_types,
  };
}

sub new {
  my $class = shift;
  my %kwargs = @_;
  my %self = (
    'kdl_type' => '', # the base type of the value in the document (string, number, boolean, null)
    'kdl_data' => '', # the actual string parsed from the document
    'type' => '', # the type annotation, if any
    'value' => '', # the parsed value
    'annotated' => 0, # flag to set to 1 if the value has an explicit type annotation
  );

  while (my ($key, $value) = each %kwargs) {
    if (exists $self{$key} && defined $value) {
      $self{$key} = $value;
    }
  }

  if (!$self{value}) {
    my ($kdl_type, $value) = $class->_parse($self{kdl_data}, $self{type});
    $self{kdl_type} = $kdl_type;
    $self{value} = $value;
  }

  return bless \%self, $class;
}

sub print {
  my ($self, $config) = @_;
  my $out = '';
  if ($self->{annotated}) {
    my $arg_type = format_identifier($self->{type});
    $out .= "($arg_type)";
  }
  $out .= $self->_format_value($config);
  return $out;
}

sub _format_value {
  my ($self, $config) = @_;
  my $out = '';
  my $grammar = $self->_get_grammar();
  if ($self->{kdl_type} eq 'string') {
    if ($self->{type} eq 'date-time') {
      # do something to turn a DateTime object into a an ISO8601 string
      # TODO: The rest of the string types in a series of elsifs
      # TODO: Some way to handle custom types with formatters/parsers
    } else {
      $out .= $self->{value};
    }
    $out = escape_string($out);
    $out = "\"$out\"";
  } elsif ($self->{kdl_type} =~ /integer|float/) {
    $out = $self->{value}->bstr();
    if (
      $config->{preserve_formatting}
      && $self->{kdl_data} =~ /^$grammar->{decimal}$/i
    ) {
      # XXX: This exists primarily to satisfy the official input/output test suite, which has
      # specific expectations about how numbers are formatted when pretty printed, which depends
      # on the shape the numbers were in when they were parsed.
      if (defined $+{dpart} && length($+{dpart}) && defined $+{epart} && length($+{epart})) {
        # print with bsstr instead, which happens to always print a whole number with an exponent part
        $out = $self->{value}->bsstr();
        # move decimal point such that there is exactly one digit left of the decimal point and
        # at least on digit to the right. If we need to add a 0 after the decimal point, do so.
        my @out = split(/e/i, $out);
        if (length($out[0]) == 1) {
          $out[0] .= '.0';
        } else {
          $out[0] = substr($out[0], 0, 1) . '.' . substr($out[0], 1);
        }
        # Join back into a string with the decimal part formatted correctly, but wrong exponent part.
        $out = join('E', @out);

        # Now we update exponent part appopriately. Parse the new string to get the decimal and
        # exponent parts, turn the exponent part into a number and add the number of places the
        # decimal point moved to it.
        $out =~ /^$grammar->{decimal}$/i;
        my $exp = $+{epart};
        # remove any underscores
        $exp =~ s/_//;
        my $offset = length($+{dpart});
        # if we added a synthetic 0 after the decimal point, the math here should ignore that
        if ($offset > 0 && $out =~ /\.0E/i) {
          $offset -= 1;
        }
        $exp = $exp + $offset;
        $out =~ s/(e\+?)(-?\d+)$/$1$exp/i;
      } elsif (defined $+{dpart} && length($+{dpart}) && $out =~ /^[^.]*$/) {
        # add a decimal part
        $out .= '.0';
      } elsif (defined $+{epart} && length($+{epart})) {
        # add an exponent part
        $out = $self->{value}->bsstr();
      }
      $out = uc $out;
    }
  } elsif ($self->{kdl_type} eq 'boolean') {
    $out = $self->{value} ? 'true' : 'false';
  } elsif ($self->{kdl_type} eq 'null') {
    $out = 'null';
  } else {
    croak "Error while formatting value, unknown kdl_type \"$self->{kdl_type}\".";
  }
  return $out;
}

sub _parse {
  my $class = shift;
  my ($value, $type) = @_;
  my $grammar = $class->_get_grammar();
  if ($value =~ /$grammar->{string}/i) {
    if (defined $type && $type =~ /$grammar->{numeric_types}/) {
      parse_error("Non-numeric value annotated with reserved numeric type ($type).");
    }
    # TODO: Validate and interpret value with type if provided
    if (defined $+{raw}) {
      return ('string', $+{raw});
    } elsif (defined $+{escaped}) {
      return ('string', unescape_string($+{escaped}));
    }
  } elsif ($value =~ /$grammar->{number}/) {
    if (defined $type && $type =~ /$grammar->{string_types}/) {
      parse_error("Numeric value annotated with reserved string type ($type).");
    }
    # TODO: Validate and interpret value with type if provided
    my $sign = $1 if $value =~ /^([-+])/;
    my $numeric_value = 0;
    if (defined $sign) {
      $value =~ s/^[-+]//;
    }
    $value =~ s/_//g;
    my $kdl_type = 'integer';
    if ($value =~ /x/) {
      $numeric_value = Math::BigInt->from_hex($value);
    } elsif ($value =~ /o/) {
      $numeric_value = Math::BigInt->from_oct($value);
    } elsif ($value =~ /b/) {
      $numeric_value = Math::BigInt->from_bin($value);
    } else {
      $kdl_type = 'float' if $value =~ /\./;
      $numeric_value = Math::BigFloat->new($value);
    }
    if ($numeric_value eq 'NaN') {
      parse_error("Invalid value: $value");
    }
    if (defined $sign && $sign eq '-') {
      return ($kdl_type, $numeric_value * -1);
    }
    return ($kdl_type, $numeric_value);
  } elsif ($value =~ /$grammar->{keyword}/) {
    if ($value eq 'true') {
      return ('boolean', 1);
    } elsif ($value eq 'false') {
      return ('boolean', 0);
    } elsif ($value eq 'null') {
      return ('null', undef);
    }
  }
  parse_error("Could not parse value ($value)");
}

1;
