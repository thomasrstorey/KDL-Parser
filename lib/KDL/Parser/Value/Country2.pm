package KDL::Parser::Value::Country2;
use parent KDL::Parser::Value::Base;

use strict;
use warnings;
use 5.01800;

use Locale::Codes;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/country2/;

sub country2 { KDL::Parser::Value::Country2->new }

sub parse {
  my ($self, $value, $tag) = @_;

  my $codes = new Locale::Codes 'country', 'alpha-2';
  $codes->show_errors(0);
  my $country = $codes->code2name($value);
  unless ($country) {
    $self->error("Not a valid ISO 3166-1 alpha-2 country code: $value");
  }
  return ('country-2', $value);
}

sub format {
  my $self = shift;

  return $self->{value};
}
