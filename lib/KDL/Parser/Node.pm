package KDL::Parser::Node;

use 5.01800;
use strict;
use warnings;
no warnings "experimental::regex_sets";

use Exporter 5.57 'import';
our @EXPORT_OK = qw/new/;

sub new {
  my $class = shift;
  my %node_hash = @_;
  my %node = (
    name => '',
    type => '',
    args => [],
    props => {},
    children => [],
  );
  while (my ($key, $value) = each %node_hash) {
    if (exists $node{$key}) {
      $node{$key} = $value;
    }
  }
  return bless \%node, $class;
}

sub print {
  my ($self, $depth) = @_;
  $depth = 0 if not defined $depth;
  my $out = ' ' x ($depth * 4);
  if ($self->{type}) {
    $out .= "($self->{type})";
  }
  $out .= $self->_format_identifier($self->{name});
  for my $arg (@{$self->{args}}) {
    $out .= ' ';
    my ($arg_type, $arg_value) = @{$arg};
    $out .= "($arg_type)" if defined $arg_type;
    $out .= $arg_value;
  }
  my @sorted_keys = sort keys(%{$self->{props}});
  for my $prop_key (@sorted_keys) {
    $out .= ' ';
    my ($prop_type, $prop_value) = @{$self->{props}{$prop_key}};
    $out .= "";
    $out .= "($prop_type)" if defined $prop_type;
    $out .= $prop_value;
  }
  if (scalar @{$self->{children}}) {
    $out .= " {\n";
    foreach ($self->{children}) {
      $out .= $_->print($depth + 1);
    }
    $out .= " " x ($depth * 4);
    $out .= "}\n";
  }
  return $out;
}

sub _format_identifier {
  my $self = shift;
  if (!/^(?[ \S & [^\/(){}<>;\[\]=,"] ])+$/) {
    return qq{"$_"};
  }
  return $_;
}
