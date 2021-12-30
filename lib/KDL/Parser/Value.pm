package KDL::Parser::Value;

use 5.01800;
use strict;
use warnings;
no warnings "experimental::regex_sets";

use Carp;

use KDL::Parser::Value::I8 qw(i8);

use Exporter 5.57 'import';
our @EXPORT_OK = qw/get_value_type_tags/;

my $verbose = 0;

sub get_value_type_tags {
  my $config = shift;
  my $standard_type_tags = {
    # Signed integers
    i8 => i8,
    i16 => undef,
    i32 => undef,
    i64 => undef,
    # Unsigned integers
    u8 => undef,
    u16 => undef,
    u32 => undef,
    u64 => undef,
    # Platform-dependent integer types, both signed and unsigned
    isize => undef,
    usize => undef,
    # IEEE 754 floating point numbers, both single (32) and double (64) precision
    f32 => undef,
    f64 => undef,
    # IEEE 754-2008 decimal floating point numbers
    decimal64 => undef,
    decimal128 => undef,
    'date-time' => undef, # ISO8601 date/time format.
    time => undef, # "Time" section of ISO8601.
    date => undef, # "Date" section of ISO8601.
    duration => , # ISO8601 duration format.
    decimal => , # IEEE 754-2008 decimal string format.
    currency => , # ISO 4217 currency code.
    'country-2' => undef, # ISO 3166-1 alpha-2 country code.
    'country-3' => undef, # ISO 3166-1 alpha-3 country code.
    'country-subdivision' => undef, # ISO 3166-2 country subdivision code.
    email => undef, # RFC5302 email address.
    'idn-email' => undef, # RFC6531 internationalized email address.
    hostname => undef, # RFC1132 internet hostname.
    'idn-hostname' => undef, # RFC5890 internationalized internet hostname.
    ipv4 => undef, # RFC2673 dotted-quad IPv4 address.
    ipv6 => undef, # RFC2373 IPv6 address.
    url => undef, # RFC3986 URI.
    'url-reference' => undef, # RFC3986 URI Reference.
    irl => undef, # RFC3987 Internationalized Resource Identifier.
    'irl-reference' => undef, #RFC3987 Internationalized Resource Identifier Reference.
    'url-template' => undef, # RFC6570 URI Template.
    uuid => undef, # RFC4122 UUID.
    regex => undef, #Regular expression. Specific patterns may be implementation-dependent.
    base64 => undef, # A Base64-encoded string, denoting arbitrary binary data.
  };
  if (defined $config->{value_type_tags}) {
    return { %{$standard_type_tags}, %{$config->{value_type_tags}} };
  }
  return $standard_type_tags;
}

1;
