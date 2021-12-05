package KDL::Parser::Error;

use Carp;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/parse_error/;

sub _get_pos {
  my $self = shift;
  my $line = 1;
  my $col = 1;
  for my $i (0..pos()) {
    my $char = substr($_, $i, 1);
    $col += 1;
    if ($char eq "\n") {
      $line += 1;
      $col = 1;
    }
  }
  return ($line, $col);
}

sub parse_error {
  my $message = shift;

  my ($lineno, $colno) = _get_pos();
  croak("$message At: ($lineno, $colno)");
}
