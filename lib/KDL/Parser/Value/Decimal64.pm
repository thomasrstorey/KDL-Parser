package KDL::Parser::Value::Decimal64;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_float);

use Exporter 5.57 'import';
our @EXPORT_OK = qw/decimal64/;

sub decimal64 {
  return KDL::Parser::Value::Decimal64->new(@_);
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
