package KDL::Parser::Value::F32;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_float);
use Math::BigFloat;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/f32/;

sub f32 {
  return KDL::Parser::Value::F32->new(@_);
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
