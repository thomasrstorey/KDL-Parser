package KDL::Parser::Value::F64;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_float);
use Math::BigInt;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/f64/;

sub f64 {
  return KDL::Parser::Value::F64->new(@_);
}

sub parse {
  my $self = shift;
  my ($value, $tag) = @_;
  my $numeric_value = parse_float($value);
  return ('float', $numeric_value);
}

sub format {
  my $self = shift;
  my $out = '';
  $out .= $self->{value}->bstr();
  return $out;
}

1;
