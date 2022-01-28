sub run-git( $command, *@args ) {
    return (run "git", $command, |@args, :out).out;
}

unit class Git::File::History;

has $!reflog;
has @!commits;
has %!files;

method new( $directory = ".") {
    my $cwd = $*CWD;
    try {
        chdir($directory);
        CATCH {
            fail("Changing to $directory did not work; $!")
        }
    }
    my @reflog = run-git( "reflog" ).lines;
    my @commits;
    my %file-history;
    for @reflog.map: *.substr(0,7) -> $commit {
        my @output = run-git( "show", "--name-only", "--format=%ci", $commit).lines;
        for @output[2..*] -> $file {
            my $file-in-commit = run-git( "show", "$commit:$file");
            my $snapshot = {
                date=> @output[0],
                state=> $file-in-commit
            };
            if %file-history{$file} {
                %file-history{$file}.push: $snapshot;
            } else {
                %file-history{$file} = [ $snapshot ];
            }
        }
        @commits.push: { date => @output[0], files => @output[2..*]};
    }
    say(@commits);
    if $*CWD ne $cwd {
        chdir $cwd;
    }
    self.bless( :@reflog, :@commits );
}
