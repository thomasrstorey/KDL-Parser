package KDL::Parser::Value::Time;
use parent KDL::Parser::Value::Base;

use strict;
use warnings;
use 5.01800;

use DateTime;
use DateTime::Format::ISO8601;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/time/;

sub time { KDL::Parser::Value::Time->new }

sub parse {
  my ($self, $value, $tag) = @_;
  # For now, we are going to parse and format as a datetime since some
  # of the valid/expected time formats are not supported by parse_time
  my $datetime = DateTime::Format::ISO8601->parse_datetime($value);
  return ('time', $datetime);
}

sub format {
  my $self = shift;

  return DateTime::Format::ISO8601->format_datetime($self->{value});
}
