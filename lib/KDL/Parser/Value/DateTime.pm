package KDL::Parser::Value::DateTime;
use parent KDL::Parser::Value::Base;

use strict;
use warnings;
use 5.01800;
no warnings "experimental::regex_sets";

use DateTime;
use DateTime::Format::ISO8601;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/datetime/;

sub datetime { KDL::Parser::Value::DateTime->new }

sub parse {
  my ($self, $value, $tag) = @_;

  my $datetime = DateTime::Format::ISO8601->parse_datetime($value);
  return ('date-time', $datetime);
}

sub format {
  my $self = shift;

  return DateTime::Format::ISO8601->format_datetime($self->{value});
}
