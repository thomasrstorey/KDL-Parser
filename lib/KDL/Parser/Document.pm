package KDL::Parser::Document;

use 5.01800;
use strict;
use warnings;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/new/;

sub new {
  my $class = shift;
  my @nodes;
  return bless {nodes => \@nodes}, $class;
}

sub print {
  my $self = shift;
  my $out = '';
  if (scalar @{$self->{nodes}}) {
    for my $node (@{$self->{nodes}}) {
      $out .= $node->print();
    }
  } else {
    $out .= "\n";
  }
  return $out;
}

sub push {
  my $self = shift;
  push @{$self->{nodes}}, @_;
}

1;
