use Test;

use Git::File::History;

throws-like { my $broken = Git::File::History.new( "foo" ) }, X::AdHoc,
        message => /Changing/, "Only correct directories";
done-testing;
