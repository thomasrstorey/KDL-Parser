use strict;
use warnings;
use utf8;
use 5.10.0;

use Test::More tests => 1;

use KDL::Parser;

my $parser = KDL::Parser->new();
my @document = $parser->parse_file('t/kdl/test.kdl');
ok($document[0] eq 'foo', 'extract node name');
