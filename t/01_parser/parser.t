use strict;
use warnings;
use utf8;

use Test::More;
use Test::Exception;
use KDL::Parser;

my $verbose = 1;

sub read_expected {
  my $fn = shift;
  open my $kdl_fh, '<:encoding(UTF-8)', "t/kdl/test_cases/expected_kdl/$fn" or die $!;
  return do { local $/ = undef; <$kdl_fh> };
}

sub matches_expected {
  my $fn = shift;
  my $parser = KDL::Parser->new();
  my $document = $parser->parse_file("t/kdl/test_cases/input/$fn");
  my $config;
  $config->{preserve_formatting} = 1;
  my $output = $document->to_kdl($config);
  my $expected = read_expected($fn);
  warn "\nOutput:\n", $output if $verbose;
  warn "\nExpected:\n", $expected if $verbose;
  ok($output eq $expected, "generated kdl matches expected kdl for $fn");
}

sub fails_to_parse {
  my $fn = shift;
  my $parser = KDL::Parser->new();
  warn "Expect $fn to fail\n" if $verbose;
  throws_ok(
    sub { $parser->parse_file("t/kdl/test_cases/input/$fn") },
    qr//i,
    "invalid input kdl throws an exception for $fn"
  );
}

matches_expected('all_node_fields.kdl');
matches_expected('arg_and_prop_same_name.kdl');
matches_expected('arg_false_type.kdl');
matches_expected('arg_float_type.kdl');
matches_expected('arg_hex_type.kdl');
matches_expected('arg_null_type.kdl');
matches_expected('arg_raw_string_type.kdl');
matches_expected('arg_string_type.kdl');
matches_expected('arg_true_type.kdl');
matches_expected('arg_type.kdl');
matches_expected('arg_zero_type.kdl');
matches_expected('asterisk_in_block_comment.kdl');
matches_expected('bare_emoji.kdl');
matches_expected('binary.kdl');
matches_expected('binary_trailing_underscore.kdl');
matches_expected('binary_underscore.kdl');
matches_expected('blank_arg_type.kdl');
matches_expected('blank_node_type.kdl');
matches_expected('blank_prop_type.kdl');
matches_expected('block_comment_after_node.kdl');
matches_expected('block_comment_before_node.kdl');
matches_expected('block_comment_before_node_no_space.kdl');
matches_expected('block_comment.kdl');
matches_expected('block_comment_newline.kdl');
matches_expected('boolean_arg.kdl');
matches_expected('boolean_prop.kdl');
matches_expected('commented_arg.kdl');
matches_expected('commented_child.kdl');
matches_expected('commented_line.kdl');
matches_expected('commented_node.kdl');
matches_expected('commented_prop.kdl');
matches_expected('crlf_between_nodes.kdl');
matches_expected('emoji.kdl');
matches_expected('empty_child_different_lines.kdl');
matches_expected('empty_child.kdl');
matches_expected('empty_child_same_line.kdl');
matches_expected('empty_child_whitespace.kdl');
matches_expected('empty.kdl');
matches_expected('empty_quoted_node_id.kdl');
matches_expected('empty_quoted_prop_key.kdl');
matches_expected('empty_string_arg.kdl');
matches_expected('escline.kdl');
matches_expected('escline_line_comment.kdl');
matches_expected('escline_node.kdl');
matches_expected('esc_newline_in_string.kdl');
matches_expected('esc_unicode_in_string.kdl');
matches_expected('false_prefix_in_bare_id.kdl');
matches_expected('false_prefix_in_prop_key.kdl');
matches_expected('hex_int.kdl');
matches_expected('hex_int_underscores.kdl');
matches_expected('hex.kdl');
matches_expected('hex_leading_zero.kdl');
matches_expected('int_multiple_underscore.kdl');
matches_expected('just_block_comment.kdl');
matches_expected('just_child.kdl');
matches_expected('just_newline.kdl');
matches_expected('just_node_id.kdl');
matches_expected('just_space.kdl');
matches_expected('leading_newline.kdl');
matches_expected('leading_zero_binary.kdl');
matches_expected('leading_zero_int.kdl');
matches_expected('leading_zero_oct.kdl');
matches_expected('multiline_comment.kdl');
matches_expected('multiline_nodes.kdl');
matches_expected('multiline_string.kdl');
matches_expected('negative_exponent.kdl');
matches_expected('negative_float.kdl');
matches_expected('negative_int.kdl');
matches_expected('nested_block_comment.kdl');
matches_expected('nested_children.kdl');
matches_expected('nested_comments.kdl');
matches_expected('nested_multiline_block_comment.kdl');
matches_expected('newline_between_nodes.kdl');
matches_expected('newlines_in_block_comment.kdl');
matches_expected('no_decimal_exponent.kdl');
matches_expected('node_false.kdl');
matches_expected('node_true.kdl');
matches_expected('node_type.kdl');
matches_expected('null_arg.kdl');
matches_expected('null_prefix_in_bare_id.kdl');
matches_expected('null_prefix_in_prop_key.kdl');
matches_expected('null_prop.kdl');
matches_expected('numeric_arg.kdl');
matches_expected('numeric_prop.kdl');
matches_expected('octal.kdl');
matches_expected('only_cr.kdl');
matches_expected('only_line_comment_crlf.kdl');
matches_expected('only_line_comment.kdl');
matches_expected('only_line_comment_newline.kdl');
matches_expected('parse_all_arg_types.kdl');
matches_expected('positive_exponent.kdl');
matches_expected('positive_int.kdl');
matches_expected('preserve_duplicate_nodes.kdl');
matches_expected('preserve_node_order.kdl');
matches_expected('prop_false_type.kdl');
matches_expected('prop_float_type.kdl');
matches_expected('prop_hex_type.kdl');
matches_expected('prop_null_type.kdl');
matches_expected('prop_raw_string_type.kdl');
matches_expected('prop_string_type.kdl');
matches_expected('prop_true_type.kdl');
matches_expected('prop_type.kdl');
matches_expected('prop_zero_type.kdl');
matches_expected('quoted_arg_type.kdl');
matches_expected('quoted_node_name.kdl');
matches_expected('quoted_node_type.kdl');
matches_expected('quoted_numeric.kdl');
matches_expected('quoted_prop_name.kdl');
matches_expected('quoted_prop_type.kdl');
matches_expected('raw_arg_type.kdl');
matches_expected('raw_node_name.kdl');
matches_expected('raw_node_type.kdl');
matches_expected('raw_prop_type.kdl');
matches_expected('raw_string_arg.kdl');
matches_expected('raw_string_backslash.kdl');
matches_expected('raw_string_hash_no_esc.kdl');
matches_expected('raw_string_just_backslash.kdl');
matches_expected('raw_string_just_quote.kdl');
matches_expected('raw_string_multiple_hash.kdl');
matches_expected('raw_string_newline.kdl');
matches_expected('raw_string_prop.kdl');
matches_expected('raw_string_quote.kdl');
matches_expected('repeated_arg.kdl');
matches_expected('repeated_prop.kdl');
matches_expected('r_node.kdl');
matches_expected('same_args.kdl');
matches_expected('same_name_nodes.kdl');
matches_expected('sci_notation_large.kdl');
matches_expected('sci_notation_small.kdl');
matches_expected('semicolon_after_child.kdl');
matches_expected('semicolon_in_child.kdl');
matches_expected('semicolon_separated.kdl');
matches_expected('semicolon_separated_nodes.kdl');
matches_expected('semicolon_terminated.kdl');
matches_expected('single_arg.kdl');
matches_expected('single_prop.kdl');
matches_expected('slashdash_arg_after_newline_esc.kdl');
matches_expected('slashdash_arg_before_newline_esc.kdl');
matches_expected('slashdash_child.kdl');
matches_expected('slashdash_empty_child.kdl');
matches_expected('slashdash_full_node.kdl');
matches_expected('slashdash_in_slashdash.kdl');
matches_expected('slashdash_negative_number.kdl');
matches_expected('slashdash_node_in_child.kdl');
matches_expected('slashdash_node_with_child.kdl');
matches_expected('slashdash_only_node.kdl');
matches_expected('slashdash_only_node_with_space.kdl');
matches_expected('slashdash_prop.kdl');
matches_expected('slashdash_raw_prop_key.kdl');
matches_expected('slashdash_repeated_prop.kdl');
matches_expected('string_arg.kdl');
matches_expected('string_prop.kdl');
matches_expected('tab_space.kdl');
matches_expected('trailing_crlf.kdl');
matches_expected('trailing_underscore_hex.kdl');
matches_expected('trailing_underscore_octal.kdl');
matches_expected('true_prefix_in_bare_id.kdl');
matches_expected('true_prefix_in_prop_key.kdl');
matches_expected('two_nodes.kdl');
matches_expected('underscore_in_exponent.kdl');
matches_expected('underscore_in_float.kdl');
matches_expected('underscore_in_fraction.kdl');
matches_expected('underscore_in_int.kdl');
matches_expected('underscore_in_octal.kdl');
matches_expected('unusual_bare_id_chars_in_quoted_id.kdl');
matches_expected('unusual_chars_in_bare_id.kdl');
matches_expected('zero_arg.kdl');
matches_expected('zero_float.kdl');
matches_expected('zero_int.kdl');

fails_to_parse('backslash_in_bare_id.kdl');
fails_to_parse('bare_arg.kdl');
fails_to_parse('brackets_in_bare_id.kdl');
fails_to_parse('chevrons_in_bare_id.kdl');
fails_to_parse('comma_in_bare_id.kdl');
fails_to_parse('comment_after_arg_type.kdl');
fails_to_parse('comment_after_node_type.kdl');
fails_to_parse('comment_after_prop_type.kdl');
fails_to_parse('comment_in_arg_type.kdl');
fails_to_parse('comment_in_node_type.kdl');
fails_to_parse('comment_in_prop_type.kdl');
fails_to_parse('dash_dash.kdl');
fails_to_parse('dot_but_no_fraction_before_exponent.kdl');
fails_to_parse('dot_but_no_fraction.kdl');
fails_to_parse('dot_in_exponent.kdl');
fails_to_parse('dot_zero.kdl');
fails_to_parse('empty_arg_type.kdl');
fails_to_parse('empty_node_type.kdl');
fails_to_parse('empty_prop_type.kdl');
fails_to_parse('escline_comment_node.kdl');
fails_to_parse('false_prop_key.kdl');
fails_to_parse('illegal_char_in_binary.kdl');
fails_to_parse('illegal_char_in_hex.kdl');
fails_to_parse('illegal_char_in_octal.kdl');
fails_to_parse('just_space_in_arg_type.kdl');
fails_to_parse('just_space_in_node_type.kdl');
fails_to_parse('just_space_in_prop_type.kdl');
fails_to_parse('just_type_no_arg.kdl');
fails_to_parse('just_type_no_node_id.kdl');
fails_to_parse('just_type_no_prop.kdl');
fails_to_parse('multiple_dots_in_float_before_exponent.kdl');
fails_to_parse('multiple_dots_in_float.kdl');
fails_to_parse('multiple_es_in_float.kdl');
fails_to_parse('multiple_x_in_hex.kdl');
fails_to_parse('no_digits_in_hex.kdl');
fails_to_parse('null_prop_key.kdl');
fails_to_parse('parens_in_bare_id.kdl');
fails_to_parse('question_mark_at_start_of_int.kdl');
fails_to_parse('question_mark_before_number.kdl');
fails_to_parse('quote_in_bare_id.kdl');
fails_to_parse('slash_in_bare_id.kdl');
fails_to_parse('space_after_arg_type.kdl');
fails_to_parse('space_after_node_type.kdl');
fails_to_parse('space_after_prop_type.kdl');
fails_to_parse('space_in_arg_type.kdl');
fails_to_parse('space_in_node_type.kdl');
fails_to_parse('space_in_prop_type.kdl');
fails_to_parse('square_bracket_in_bare_id.kdl');
fails_to_parse('true_prop_key.kdl');
fails_to_parse('type_before_prop_key.kdl');
fails_to_parse('unbalanced_raw_hashes.kdl');
fails_to_parse('underscore_at_start_of_fraction.kdl');
fails_to_parse('underscore_at_start_of_hex.kdl');
fails_to_parse('underscore_at_start_of_int.kdl');
fails_to_parse('underscore_before_number.kdl');

done_testing();

1;
