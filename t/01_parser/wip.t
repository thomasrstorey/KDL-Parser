use strict;
use warnings;
use utf8;

use Test::More tests => 1;

use KDL::Parser;

my $parser = KDL::Parser->new();
my $document = $parser->parse_file('t/kdl/test.kdl');
ok(@{$document->{nodes}}[0]->{name} eq 'foo', 'extract node name');
