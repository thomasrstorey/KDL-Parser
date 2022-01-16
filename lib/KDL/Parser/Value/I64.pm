package KDL::Parser::Value::I64;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_integer);
use Math::BigInt;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/i64/;

my $I64_LIMIT = Math::BigInt->new('9223372036854775807');

sub i64 {
  return KDL::Parser::Value::I64->new(@_);
}

sub parse {
  my $self = shift;
  my ($value, $tag) = @_;
  my $numeric_value = parse_integer($value);
  if ($numeric_value < (-1 * $I64_LIMIT) || $numeric_value > $I64_LIMIT) {
    $self->error("Value outside of valid range for 64 bit signed integer: $numeric_value");
  }
  return ('integer', $numeric_value);
}

sub format {
  my $self = shift;
  my $out = '';
  $out .= $self->{value}->bstr();
  return $out;
}

1;
