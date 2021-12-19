# NAME

KDL::Parser - Perl implementation of a KDL parser.

# SYNOPSIS

    use KDL::Parser;

    my $parser = KDL::Parser->new();
    my $document = $parser->parse_file('path/to/file.kdl');
    # document is a hash with a `nodes` property
    for my $node (@{$document->{nodes}}) {
      say $node->{name};
    }
    $document->print();

# DESCRIPTION

KDL::Parser is a Perl implementation of the KDL (pronounced like "cuddle") document language.
Learn more at [https://github.com/kdl-org/kdl](https://github.com/kdl-org/kdl).

Currently it should be compatible with the KDL spec in terms of parsing and printing. However,
in this early release there is no type handling outside of that required to handle string,
number, and keyword values appropriately for pretty-printing.

# LICENSE

Copyright (C) Thomas R Storey.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Thomas R Storey <orey.st@protonmail.com>
