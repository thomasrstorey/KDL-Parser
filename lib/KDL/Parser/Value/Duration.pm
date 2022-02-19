package KDL::Parser::Value::Duration;
use parent KDL::Parser::Value::Base;

use strict;
use warnings;
use 5.01800;

use DateTime;
use DateTime::Format::Duration::ISO8601;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/duration/;

sub duration { KDL::Parser::Value::Duration->new }

sub parse {
  my ($self, $value, $tag) = @_;

  my $datetime = DateTime::Format::Duration::ISO8601->parse_duration($value);
  return ('date-time', $datetime);
}

sub format {
  my $self = shift;

  return DateTime::Format::Duration::ISO8601->format_duration($self->{value});
}
