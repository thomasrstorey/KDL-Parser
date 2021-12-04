package KDL::Parser::Node;

use 5.01800;
use strict;
use warnings;
no warnings "experimental::regex_sets";

use Data::Dumper;
use Exporter 5.57 'import';
our @EXPORT_OK = qw/new/;

my $verbose = 0;

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
    if (exists $node{$key} && defined $value) {
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
  my $name = $self->_format_identifier($self->{name});
  $out .= $name;
  for my $arg ($self->{args}) {
    if (scalar(@{$arg}) == 0) {
      last;
    }
    warn Dumper($arg) if $verbose;
    $out .= ' ';
    my ($arg_type, $arg_value) = @{$arg};
    if (defined $arg_type) {
      $arg_type = $self->_format_identifier($arg_type);
      $out .= "($arg_type)";
    }
    # TODO: need to know if $arg_value is a string or a number, which apparently in perl
    # is kinda hard to do. If it's a string we need to escape the string and wrap it
    # in quotes.
    $out .= $arg_value;
  }
  my @sorted_keys = sort keys(%{$self->{props}});
  for my $prop_key (@sorted_keys) {
    $out .= ' ';
    $out .= "$prop_key=";
    my ($prop_type, $prop_value) = @{$self->{props}{$prop_key}};
    $out .= "($prop_type)" if defined $prop_type;
    $out .= "$prop_value";
  }
  if (scalar @{$self->{children}}) {
    $out .= " {\n";
    for my $child (@{$self->{children}}) {
      $out .= $child->print($depth + 1);
    }
    $out .= " " x ($depth * 4);
    $out .= "}";
  }
  $out .= "\n";
  return $out;
}

sub _format_identifier {
  my ($self, $ident) = @_;
  if ($ident !~ /^(?[ \S & [^\/(){}<>;\[\]=,"] ])+$/) {
    return qq{"$ident"};
  }
  return $ident;
}

1;
