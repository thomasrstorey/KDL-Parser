package KDL::Parser::Value::Currency;
use parent KDL::Parser::Value::Base;

use strict;
use warnings;
use 5.01800;

use Locale::Codes::Currency qw(code2currency);

use Exporter 5.57 'import';
our @EXPORT_OK = qw/currency/;

sub currency { KDL::Parser::Value::Currency->new }

sub parse {
  my ($self, $value, $tag) = @_;

  my $currency = code2currency($value);
  unless ($currency) {
    $self->error("Not a valid ISO 4217 currency code: $value");
  }
  return ('currency', $value);
}

sub format {
  my $self = shift;

  return $self->{value};
}
