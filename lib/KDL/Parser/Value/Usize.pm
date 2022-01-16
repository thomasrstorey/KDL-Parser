package KDL::Parser::Value::Usize;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_integer);
use Math::BigInt;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/usize/;

my $U64_LIMIT = Math::BigInt->new('18446744073709551615');
my $U32_LIMIT = Math::BigInt->new('4294967295');

sub usize {
  return KDL::Parser::Value::Usize->new(@_);
}

sub parse {
  my $self = shift;
  my ($value, $tag) = @_;
  my ($limit, $bits) = +(~0 >> 31) - 1 ? ($U64_LIMIT, 64) : ($U32_LIMIT, 32);
  my $numeric_value = parse_integer($value);
  if ($numeric_value < 0 || $numeric_value > $limit) {
    $self->error("Value outside of valid range for $bits bit unsigned integer: $numeric_value");
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
