sub run-git( $command, *@args ) {
    return (run "git", $command, |@args, :out).out;
}

unit class Git::File::History;

has @!commits;
has %!file-history;

submethod BUILD( :@!commits, :%!file-history) {};

method new( $directory = ".", :$glob ) {
    my $cwd = $*CWD;
    try {
        chdir($directory);
        CATCH {
            fail("Changing to $directory did not work")
        }
    };
    my @reflog;
    if $glob {
        @reflog = run-git("reflog", $glob ).lines;
    } else {
        @reflog = run-git("reflog").lines;
    }
    my @commits;
    my %file-history;
    for @reflog.map: *.substr(0,7) -> $commit {
        my @output = run-git( "show", "--name-status", "--format=%ci", $commit)
                .lines;
        for @output[2..*] -> $file-status {
            my ($status,$file) = $file-status.split(/\s+/);
            if ( $status ne "D") {
                my $file-in-commit = run-git(
                        "show",
                        "$commit:$file").slurp(:close);
                my $snapshot = {
                    date => @output[0],
                    state => $file-in-commit
                };
                if ( %file-history{$file} ) {
                    %file-history{$file}.push: $snapshot;
                } else {
                    %file-history{$file} = [$snapshot];
                }
            }
        }
        @commits.push: { date => @output[0], files => @output[2..*]};
    }
    if $*CWD ne $cwd {
        chdir $cwd;
    }
    self.bless( :@commits, :%file-history );
}

method history-of( Str $file where %!file-history{*}.defined ) {
    return %!file-history{$file};
}
