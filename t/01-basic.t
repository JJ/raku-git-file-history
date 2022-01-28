use Test;

use Git::File::History;

throws-like { my $broken = Git::File::History.new( "foo" ) }, X::AdHoc,
        message => /Changing/, "Only correct directories";

my $current-dir = $*CWD;
my $good = Git::File::History.new();
is( $current-dir, $*CWD, "Didn't change the directory");
isa-ok( $good, Git::File::History, "Object created" );

ok( $good.history-of( "README.md"), "Contains history of known files");
done-testing;
