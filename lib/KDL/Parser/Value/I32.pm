package KDL::Parser::Value::I32;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_integer);
use Math::BigInt;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/i32/;

my $I32_LIMIT = Math::BigInt->new('2147483647');

sub i32 {
  return KDL::Parser::Value::I32->new(@_);
}

sub parse {
  my $self = shift;
  my ($value, $tag) = @_;
  my $numeric_value = parse_integer($value);
  if ($numeric_value < (-1 * $I32_LIMIT) || $numeric_value > $I32_LIMIT) {
    $self->error("Value outside of valid range for 32 bit signed integer: $numeric_value");
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
