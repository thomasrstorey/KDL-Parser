package KDL::Parser::Value::Any;
use parent KDL::Parser::Value::Base;

use Carp;
use Math::BigFloat;
use Math::BigInt;

use KDL::Parser::Util qw(unescape_string escape_string format_identifier);
use KDL::Parser::Error qw(parse_error);

use Exporter 5.57 'import';
our @EXPORT_OK = qw/parse_integer parse_float/;

sub format {
  my ($self, $config) = @_;
  my $out = '';
  my $grammar = $self->_get_grammar();
  if ($self->{type} eq 'string') {
    $out .= $self->{value};
    $out = escape_string($out);
    $out = "\"$out\"";
  } elsif ($self->{type} =~ /integer|float/) {
    $out = $self->{value}->bstr();
    if (
      $config->{preserve_formatting}
      && $self->{fragment} =~ /^$grammar->{decimal}$/i
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
  } elsif ($self->{type} eq 'boolean') {
    $out = $self->{value} ? 'true' : 'false';
  } elsif ($self->{type} eq 'null') {
    $out = 'null';
  } else {
    croak "Error while formatting value, unknown type \"$self->{type}\".";
  }
  return $out;
}

sub parse {
  my $class = shift;
  my ($value, $tag) = @_;
  my $grammar = $class->_get_grammar();
  if ($value =~ /$grammar->{string}/i) {
    if (defined $+{raw}) {
      return ('string', $+{raw});
    } elsif (defined $+{escaped}) {
      return ('string', unescape_string($+{escaped}));
    }
  } elsif ($value =~ /$grammar->{number}/) {
    my $type = $value =~ /\./ ? 'float' : 'integer';
    if ($type eq 'integer') {
      return ($type, parse_integer($value));
    } else {
      return ($type, parse_float($value));
    }
  } elsif ($value =~ /$grammar->{keyword}/) {
    if ($value eq 'true') {
      return ('boolean', 1);
    } elsif ($value eq 'false') {
      return ('boolean', 0);
    } elsif ($value eq 'null') {
      return ('null', undef);
    }
  }
  $self->error("Could not parse value ($value)");
}

sub parse_integer {
    my $value = shift;
    my $sign = $1 if $value =~ /^([-+])/;
    my $numeric_value = 0;
    if (defined $sign) {
      $value =~ s/^[-+]//;
    }
    $value =~ s/_//g;
    if ($value =~ /x/) {
      $numeric_value = Math::BigInt->from_hex($value);
    } elsif ($value =~ /o/) {
      $numeric_value = Math::BigInt->from_oct($value);
    } elsif ($value =~ /b/) {
      $numeric_value = Math::BigInt->from_bin($value);
    } else {
      $numeric_value = Math::BigInt->new($value);
    }
    if ($numeric_value eq 'NaN') {
      parse_error("Invalid value: $value");
    }
    if (defined $sign && $sign eq '-') {
      return $numeric_value * -1;
    }
    return $numeric_value;
}

sub parse_float {
    my $value = shift;
    my $numeric_value = 0;
    $value =~ s/_//g;
    $numeric_value = Math::BigFloat->new($value);
    if ($numeric_value eq 'NaN') {
      parse_error("Invalid value: $value");
    }
    return $numeric_value;
}

1;
