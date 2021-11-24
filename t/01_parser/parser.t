use strict;
use warnings;
use utf8;

use Test::More tests => 2;
use KDL::Parser;

my $verbose = 0;

sub read_expected {
  my $fn = shift;
  open my $kdl_fh, '<:encoding(UTF-8)', "t/kdl/test_cases/expected_kdl/$fn" or die $!;
  return do { local $/ = undef; <$kdl_fh> };
}

sub matches_expected {
  my $fn = shift;
  my $parser = KDL::Parser->new();
  my $document = $parser->parse_file("t/kdl/test_cases/input/$fn");
  my $output = $document->print();
  my $expected = read_expected($fn);
  warn "\n", $output if $verbose;
  warn "\n", $expected if $verbose;
  ok($output eq $expected, "generated kdl matches expected kdl for $fn");
}

matches_expected('all_node_fields.kdl');
matches_expected('arg_and_prop_same_name.kdl');

1;
