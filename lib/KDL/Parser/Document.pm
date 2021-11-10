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
  foreach ($self->{nodes}) {
    $out .= $_->print();
  }
}

sub push {
  my $self = shift;
  push @{$self->{nodes}}, @_;
}
