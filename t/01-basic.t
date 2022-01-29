use Test;

use Git::File::History;

throws-like { my $broken = Git::File::History.new( "foo" ) }, X::AdHoc,
        message => /Changing/, "Only correct directories";

my $current-dir = $*CWD;
my $good = Git::File::History.new();
is( $current-dir, $*CWD, "Didn't change the directory");
isa-ok( $good, Git::File::History, "Object created" );

ok( $good.history-of( "README.md"), "Contains history of known files");

run( "git", "clone", "https://github.com/JJ/raku-git-file-history");
my $with-files = Git::File::History.new( "raku-git-file-history",
        :files("t/*.t"));
isa-ok( $with-files, Git::File::History, "Object with files created" );
my @file-history = $with-files.history-of( "t/01-basic.t");
ok( @file-history, "Contains history of known files");

cmp-ok(@file-history.elems, ">=", 2,
            "This file has been changed more than 3 times");
is(@file-history[0]<date> cmp @file-history[1]<date>,
            Less, "Correct chronological order");
run( "rm", "-rf", "raku-git-file-history");

done-testing;
