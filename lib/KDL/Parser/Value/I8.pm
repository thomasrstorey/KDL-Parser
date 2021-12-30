package KDL::Parser::Value::I8;

use parent KDL::Parser::Value::Base;
use KDL::Parser::Value::Any qw(parse_integer);

use Exporter 5.57 'import';
our @EXPORT_OK = qw/i8/;

sub i8 {
  my $class = shift;
  return $class->new(@_);
}

sub parse {

}

sub to_kdl {

}

1;
