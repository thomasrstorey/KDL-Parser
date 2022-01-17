use strict;
use warnings;
use utf8;

use Scalar::Util 'blessed';
use Test::More;
use Test::Exception;

use KDL::Parser;

my $parser = KDL::Parser->new();
my $document = $parser->parse('
succeed (i32)-45_899
');
ok(
  blessed($document->{nodes}[0]->{args}[0]) eq 'KDL::Parser::Value::I32',
  'values tagged with (i32) get represented by KDL::Parser::Value::I32 objects'
);
ok($document->{nodes}[0]->{args}[0]->{value} == -45_899, 'i32 type allows negative values in range');
ok($document->to_kdl() eq 'succeed (i32)-45899
', 'i32 type formats correctly');
throws_ok(
  sub { $parser->parse('
fail (i32)9999999999
') },
  qr/Value outside of valid range for 32 bit signed integer/,
  "i32 type should not allow invalid values"
);

done_testing();

1;
