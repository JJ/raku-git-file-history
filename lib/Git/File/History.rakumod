sub run-git( $command, *@args ) {
    if @args.grep: /".jpg"|".png"/ {
        return "Binary file";
    }
    my $result = run "git", $command, |@args, :out;
    return $result.out;
}

sub this-a-repo() is export {
    return so
    (run "git", "status", :out, :err).err.slurp(:close) !~~ /fatal/;
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

     if !this-a-repo() {
        chdir($cwd);
        fail("$directory is not a repo");
    }
    my @reflog;
    if $glob {
        @reflog = run-git("log", "--all", "--oneline", $glob ).lines;
    } else {
        @reflog = run-git("log", "--all", "--oneline").lines;
    }
    my @commits;
    my %file-history;
    for @reflog.map: *.substr(0,7) -> $commit {
        my @output = run-git( "show", "--name-status", "--format=%cI", $commit)
                .lines;
        for @output[2..*] -> $file-status {
            my ($status,$file) = $file-status.split(/\s+/);
            if ( $status ne "D") {
                my $file-in-commit-result = run-git(
                        "show",
                        "$commit:$file");
                my $file-in-commit;
                if $file-in-commit-result !~~ Str {
                    $file-in-commit = $file-in-commit-result.slurp: :close;
                } else {
                    $file-in-commit = $file-in-commit-result;
                }
                my $snapshot = {
                    date => @output[0],
                    state => $file-in-commit;
                };
                if ( %file-history{$file} ) {
                    %file-history{$file}.push: $snapshot;
                } else {
                    %file-history{$file} = [$snapshot];
                }
            }
        }
        @commits.push: {
            date => DateTime.new(@output[0]),
            files => @output[2..*]
        };
    }
    if $*CWD ne $cwd {
        chdir $cwd;
    }
    self.bless( :@commits, :%file-history );
}

method history-of( Str $file where %!file-history{*}.defined ) {
    return %!file-history{$file}.reverse;
}
