package KDL::Parser::Value::Isize;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_integer);
use Math::BigInt;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/isize/;

my $I64_LIMIT = Math::BigInt->new();
my $I32_LIMIT = Math::BigInt->new();

sub isize {
  return KDL::Parser::Value::Isize->new(@_);
}

sub parse {
  my $self = shift;
  my ($value, $tag) = @_;
  my ($limit, $bits) = +(~0 >> 31) - 1 ? ($I64_LIMIT, 64) : ($I32_LIMIT, 32);
  my $numeric_value = parse_integer($value);
  if ($numeric_value < (-1 * $limit) || $numeric_value > $limit) {
    $self->error("Value outside of valid range for $bits bit signed integer: $numeric_value");
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
