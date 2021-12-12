package KDL::Parser::Util;

use 5.018000;
use strict;
use warnings;
no warnings "experimental::regex_sets";

use Carp;
use KDL::Parser::Error qw(parse_error);

use Exporter 5.57 'import';
our @EXPORT_OK = qw/unescape_string escape_string format_identifier/;

sub unescape_string {
  my $esc = shift;
  my $escape = qr{["\\/bfnrtu]};

  my $unesc = "";
  for (my $i = 0; $i <= length($esc) - 1; $i += 1) {
    my $reverse_solidus = substr($esc, $i, 1);
    if ($reverse_solidus eq "\\") {
      my $esc_char = substr($esc, $i + 1, 1);
      if ($esc_char =~ /$escape/) {
        $i += 1;
      } else {
        $unesc .= $reverse_solidus;
        next;
      }
      if ($esc_char eq "n") {
        $unesc .= "\n";
      } elsif ($esc_char eq "r") {
        $unesc .= "\r";
      } elsif ($esc_char eq "t") {
        $unesc .= "\t";
      } elsif ($esc_char eq "b") {
        $unesc .= "\b";
      } elsif ($esc_char eq "f") {
        $unesc .= "\f";
      } elsif ($esc_char eq "\\") {
        $unesc .= "\\";
      } elsif ($esc_char eq "/") {
        $unesc .= "/";
      } elsif ($esc_char eq '"') {
        $unesc .= '"';
      } elsif ($esc_char eq "u") {
        my $unicode_esc = substr($esc, $i + 1);
        if ($unicode_esc =~ /^\{([a-f0-9]{1,6})\}/i) {
          $unesc .= pack('U*', hex($1));
          $i += (length($1) + 2);
        } else {
          parse_error("Malformed unicode escape sequence.");
        }
      } else {
        parse_error("Malformed character escape ($esc_char).");
      }
    } else {
      $unesc .= substr($esc, $i, 1);
    }
  }
  return $unesc;
}

sub escape_string {
  my $str = shift;

  $str =~ s/(["\\])/\\$1/g;
  $str =~ s/\cH/\\b/g; # in regex, \b is a word boundary, so we use \cH to match <BS>
  $str =~ s/\f/\\f/g;
  $str =~ s/\n/\\n/g;
  $str =~ s/\r/\\r/g;
  $str =~ s/\t/\\t/g;

  return $str;
}

sub format_identifier {
  # 'All identifiers must be unquoted unless they must be quoted.
  # That means "foo" becomes foo, and "foo bar" stays that way.'
  my $ident = shift;
  if ($ident !~ /^(?[ \S & [^\/(){}<>;\[\]=,"] ])+$/) {
    return qq{"$ident"};
  }
  return $ident;
}
