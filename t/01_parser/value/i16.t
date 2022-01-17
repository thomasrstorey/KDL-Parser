use strict;
use warnings;
use utf8;

use Scalar::Util 'blessed';
use Test::More;
use Test::Exception;

use KDL::Parser;

my $parser = KDL::Parser->new();
my $document = $parser->parse('
succeed (i16)-0xa1
');
ok(
  blessed($document->{nodes}[0]->{args}[0]) eq 'KDL::Parser::Value::I16',
  'values tagged with (i16) get represented by KDL::Parser::Value::I16 objects'
);
ok($document->{nodes}[0]->{args}[0]->{value} == -161, 'i16 type allows negative values in range');
ok($document->to_kdl() eq 'succeed (i16)-161
', 'i16 type formats correctly');
throws_ok(
  sub { $parser->parse('
fail (i16)55_222
') },
  qr/Value outside of valid range for 16 bit signed integer/,
  "i16 type should not allow invalid values"
);

done_testing();

1;
