# Git::File::History [![Test-install and cache deps](https://github.com/JJ/raku-git-file-history/actions/workflows/test.yaml/badge.svg)](https://github.com/JJ/raku-git-file-history/actions/workflows/test.yaml) ![Logo](resources/logo.png)

Get all versions of a file in a git repository. Main use case for this is
when you use the repository for storage, and want to examine the progression
of some files. Or whatever. I don't really know, it was an itch I had to
scratch and here we are.

## Installing

Usual way:

    zef install Git::File::History

## SYNOPSIS

```raku
use Git::File::History;

my $file-histories = Git::File::History.new(); # Will throw if not in a repo
say $file-histories.history-of( "README.md");

# .date contains a DateTime object, .state the contents of the file
for $file-histories.history-of( "t/01-basic.t") -> $fv {
   say $fv.date, " → ", $fv.state.split("\n").elems;
}

# Repo in another directory:
my $file-histories' = Git::File::History.new( "another/dir" );

# Limit to a few files (for big repos)
my $yet-another = Git::File::History.new( :files("t/*.t") );
```

## See also

Other [git-related stuff](https://raku.land/?q=git) in Raku land

## License

(c) 2022, 2025, JJ Merelo, jj@raku.org

This module will be licensed under the Artistic 2.0 License (the same as Raku itself).
