use Test;

use Git::File::History;

throws-like { my $broken = Git::File::History.new( "foo" ) }, X::AdHoc,
        message => /Changing/, "Only correct directories";

my $current-dir = $*CWD;
throws-like { Git::File::History.new("/tmp") },
        X::AdHoc,
        "Bails out outside a repo";

unless ( this-a-repo ) {
    done-testing;
    exit;
}

my $good = Git::File::History.new();
is( $current-dir, $*CWD, "Didn't change the directory");
isa-ok( $good, Git::File::History, "Object created" );

ok( $good.history-of( "README.md"), "Contains history of known files");

my $with-files = Git::File::History.new( :files("t/*.t"));
isa-ok( $with-files, Git::File::History, "Object with files created" );
my @file-history = $with-files.history-of( "t/01-basic.t");
ok( @file-history, "Contains history of known files");

cmp-ok(@file-history.elems, ">=", 2,
            "This file has been changed more than 3 times");
is(@file-history[0]<date> cmp @file-history[1]<date>,
            Less, "Correct chronological order");

my $test-file = Git::File::History.new( :files("resources/test"));
isa-ok( $test-file, Git::File::History,
        "Object with single test file created" );

is( $test-file.history-of("resources/test").elems, 9, "Only known changes");
done-testing;
