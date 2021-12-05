package KDL::Parser::Node;

use 5.01800;
use strict;
use warnings;
no warnings "experimental::regex_sets";

use Data::Dumper;
use KDL::Parser::Util qw(format_identifier);
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
  my $name = format_identifier($self->{name});
  $out .= $name;
  for my $arg ($self->{args}) {
    warn Dumper($arg) if $verbose;
    $out .= ' ';
    $out .= $arg->print();
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

1;
