use strict;
use warnings;
use utf8;

use Scalar::Util 'blessed';
use Test::More;
use Test::Exception;

use KDL::Parser;

my $parser = KDL::Parser->new();
my $document = $parser->parse('
succeed (i8)-99
');
ok(
  blessed($document->{nodes}[0]->{args}[0]) eq 'KDL::Parser::Value::I8',
  'values tagged with (i8) get represented by KDL::Parser::Value::I8 objects'
);
ok($document->{nodes}[0]->{args}[0]->{value} == -99, 'i8 type allows negative values in range');
ok($document->to_kdl() eq 'succeed (i8)-99
', 'i8 type formats correctly');
throws_ok(
  sub { $parser->parse('
fail (i8)256
') },
  qr/Value outside of valid range for 8 bit signed integer/,
  "i8 type should not allow invalid values"
);

done_testing();

1;
