package KDL::Parser::Value::Hostname;
use parent KDL::Parser::Value::Base;

use strict;
use warnings;
use 5.01800;

use Data::Validate::Domain qw(is_hostname);

use Exporter 5.57 'import';
our @EXPORT_OK = qw/hostname/;

sub hostname { KDL::Parser::Value::Hostname->new }

sub parse {
  my ($self, $value, $tag) = @_;
  if (is_hostname($value)) {
    return ('hostname', $value);
  }
  $self->parse_error("Not a valid RFC1123 hostname: $value");
}

sub format {
  my $self = shift;

  return $self->{value};
}
