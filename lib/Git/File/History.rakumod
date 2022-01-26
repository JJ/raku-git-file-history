unit class Git::File::History;

has $!reflog;
has @!commits;

method new( $directory = ".") {
    my $cwd = $*CWD;
    try {
        chdir($directory);
        CATCH {
            fail("Changing to $directory did not work; $!")
        }
    }
    my @reflog = (run "git", "reflog", :out).out.lines;
    my @commits;
    for @reflog.map: *.substr(0,7) -> $commit {
        @commits.push: run "git", "show", $commit, :out;
    }
    if $*CWD ne $cwd {
        chdir $cwd;
    }
    self.bless( :@reflog, :@commits );
}
