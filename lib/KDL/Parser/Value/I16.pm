package KDL::Parser::Value::I16;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_integer);

use Exporter 5.57 'import';
our @EXPORT_OK = qw/i16/;

sub i16 {
  return KDL::Parser::Value::I16->new(@_);
}

sub parse {
  my $self = shift;
  my ($value, $tag) = @_;
  my $numeric_value = parse_integer($value);
  if ($numeric_value < -32_767 || $numeric_value > 32_767) {
    $self->error("Value outside of valid range for 16 bit signed integer: $numeric_value");
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