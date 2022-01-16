package KDL::Parser::Value::U32;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_integer);
use Math::BigInt;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/u32/;

my $U32_LIMIT = Math::BigInt->new('4294967295');

sub u32 {
  return KDL::Parser::Value::U32->new(@_);
}

sub parse {
  my $self = shift;
  my ($value, $tag) = @_;
  my $numeric_value = parse_integer($value);
  if ($numeric_value < 0 || $numeric_value > $U32_LIMIT) {
    $self->error("Value outside of valid range for 32 bit unsigned integer: $numeric_value");
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
