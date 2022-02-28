package KDL::Parser::Value::Email;
use parent KDL::Parser::Value::Base;

use strict;
use warnings;
use 5.01800;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/email/;

my $email_address_qr = qr/
(?:
  [a-z0-9!#$%&'*+\/=?^_`{|}~-]+
  (?:
    \.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+
  )*
  |"
  (?:
    [\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f]
  )*
  "
)
@
(?:
  (?:
    [a-z0-9]
    (?:
      [a-z0-9-]*[a-z0-9]
    )?
    \.
  )+
  [a-z0-9]
  (?:
    [a-z0-9-]*[a-z0-9]
  )?
  |\[
  (?:
    (?:
      25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?
    )\.
  ){3}
  (?:
    25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:
    (?:
      [\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f]
    )+
  )
  \]
)/x;

sub email { KDL::Parser::Value::Email->new }

sub parse {
  my ($self, $value, $tag) = @_;
  if ($value =~ $email_address_qr) {
    return ('email', $value);
  }
  $self->parse_error("Invalid RFC5322 standard email address: $value");
}

sub format {
  my $self = shift;

  return $self->{value};
}
