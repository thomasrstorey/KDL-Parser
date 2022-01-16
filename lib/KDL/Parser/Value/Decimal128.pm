package KDL::Parser::Value::Decimal128;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_float);

use Exporter 5.57 'import';
our @EXPORT_OK = qw/decimal128/;

sub decimal128 {
  return KDL::Parser::Value::Decimal128->new(@_);
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
