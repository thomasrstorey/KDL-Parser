package KDL::Parser::Value;

use 5.01800;
use strict;
use warnings;
no warnings "experimental::regex_sets";

use Carp;

use KDL::Parser::Value::I8 qw(i8);
use KDL::Parser::Value::I16 qw(i16);
use KDL::Parser::Value::I32 qw(i32);
use KDL::Parser::Value::I64 qw(i64);
use KDL::Parser::Value::U8 qw(u8);
use KDL::Parser::Value::U16 qw(u16);
use KDL::Parser::Value::U32 qw(u32);
use KDL::Parser::Value::U64 qw(u64);
use KDL::Parser::Value::Isize qw(isize);
use KDL::Parser::Value::Usize qw(usize);
use KDL::Parser::Value::F32 qw(f32);
use KDL::Parser::Value::F64 qw(f64);
use KDL::Parser::Value::Decimal64 qw(decimal64);
use KDL::Parser::Value::Decimal128 qw(decimal128);

use Exporter 5.57 'import';
our @EXPORT_OK = qw/get_value_type_tags/;

my $verbose = 0;

sub get_value_type_tags {
  my $config = shift;
  my $standard_type_tags = {
    # Signed integers
    i8 => \&i8,
    i16 => \&i16,
    i32 => \&i32,
    i64 => \&i64,
    # Unsigned integers
    u8 => \&u8,
    u16 => \&u16,
    u32 => \&u32,
    u64 => \&u64,
    # Platform-dependent integer types, both signed and unsigned
    isize => \&isize,
    usize => \&usize,
    # IEEE 754 floating point numbers, both single (32) and double (64) precision
    f32 => \&f32,
    f64 => \&f64,
    # IEEE 754-2008 decimal floating point numbers
    decimal64 => \&decimal64,
    decimal128 => \&decimal128
    #'date-time' => undef, # ISO8601 date/time format.
    #time => undef, # "Time" section of ISO8601.
    #date => undef, # "Date" section of ISO8601.
    #duration => , # ISO8601 duration format.
    #decimal => , # IEEE 754-2008 decimal string format.
    #currency => , # ISO 4217 currency code.
    #'country-2' => undef, # ISO 3166-1 alpha-2 country code.
    #'country-3' => undef, # ISO 3166-1 alpha-3 country code.
    #'country-subdivision' => undef, # ISO 3166-2 country subdivision code.
    #email => undef, # RFC5302 email address.
    #'idn-email' => undef, # RFC6531 internationalized email address.
    #hostname => undef, # RFC1132 internet hostname.
    #'idn-hostname' => undef, # RFC5890 internationalized internet hostname.
    #ipv4 => undef, # RFC2673 dotted-quad IPv4 address.
    #ipv6 => undef, # RFC2373 IPv6 address.
    #url => undef, # RFC3986 URI.
    #'url-reference' => undef, # RFC3986 URI Reference.
    #irl => undef, # RFC3987 Internationalized Resource Identifier.
    #'irl-reference' => undef, #RFC3987 Internationalized Resource Identifier Reference.
    #'url-template' => undef, # RFC6570 URI Template.
    #uuid => undef, # RFC4122 UUID.
    #regex => undef, #Regular expression. Specific patterns may be implementation-dependent.
    #base64 => undef # A Base64-encoded string, denoting arbitrary binary data.
  };
  if (defined $config->{value_type_tags}) {
    return { %{$standard_type_tags}, %{$config->{value_type_tags}} };
  }
  return $standard_type_tags;
}

1;
