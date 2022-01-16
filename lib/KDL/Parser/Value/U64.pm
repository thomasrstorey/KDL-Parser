package KDL::Parser::Value::U64;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_integer);
use Math::BigInt;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/u64/;

my $U64_LIMIT = Math::BigInt->new('18446744073709551615');

sub u64 {
  return KDL::Parser::Value::U64->new(@_);
}

sub parse {
  my $self = shift;
  my ($value, $tag) = @_;
  my $numeric_value = parse_integer($value);
  if ($numeric_value < 0 || $numeric_value > $U64_LIMIT) {
    $self->error("Value outside of valid range for 64 bit unsigned integer: $numeric_value");
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
