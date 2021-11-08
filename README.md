# NAME

KDL::Parser - Perl implementation of a KDL parser.

# SYNOPSIS

    use KDL::Parser;

    my $parser = KDL::Parser->new();
    my $document = $parser->parse_file('path/to/file.kdl');
    # document is an array of hashes which each represent a node
    for my $node (@document) {
      say $node->{name};
    }

# DESCRIPTION

KDL::Parser is a Perl implementation of the [KDL](https://github.com/kdl-org/kdl) (pronounced like "cuddle") document language.

# LICENSE

Copyright (C) Thomas R Storey.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Thomas R Storey <orey.st@protonmail.com> @thomasrstorey
