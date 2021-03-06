use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Path::FindDev;

# ABSTRACT: Find a development path somewhere in an upper hierarchy.

# AUTHORITY

=head1 DESCRIPTION

This package is mostly a glue layer around L<< C<Path::IsDev>|Path::IsDev >>
with a few directory walking tricks.

    use Path::FindDev qw( find_dev );

    if ( my $root = find_dev('/some/path/to/something/somewhere')) {
        print "development root = $root";
    } else {
        print "No development root :(";
    }

=head1 EXAMPLE USE-CASES

Have you ever found yourself doing

    use FindBin;
    use lib "$FindBin::Bin/../../../tlib"

In a test?

Have you found yourself paranoid of file-system semantics and tried

    use FindBin;
    use Path::Tiny qw(path)
    use lib path($FindBin::Bin)->parent->parent->parent->child('tlib')->stringify;

Have you ever done either of the above in a test, only to
find you've needed to move the test to a deeper hierarchy,
and thus, need to re-write all your path resolution?

Have you ever had this problem for multiple files?

No more!

    use FindBin;
    use Path::FindDev qw(find_dev);
    use lib find_dev($FindBin::Bin)->child('t','tlib')->stringify;

^ Should work, regardless of which test you put it in, and regardless
of what C<$CWD> happens to be when you call it.

=cut

use Sub::Exporter -setup => { exports => [ find_dev => \&_build_find_dev, ] };

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Path::FindDev",
    "interface":"exporter"
}

=end MetaPOD::JSON

=cut

sub _build_find_dev {
  my ( undef, undef, $arg ) = @_;

  my $finddev_object;
  return sub {
    my ($path) = @_;
    $finddev_object ||= do {
      require Path::FindDev::Object;
      Path::FindDev::Object->new($arg);
    };
    return $finddev_object->find_dev($path);
  };
}

=func find_dev

    my $result = find_dev('/some/path');

If a C<dev> directory is found at, or above, C</some/path>, it will be returned
as a L<< C<Path::Tiny>|Path::Tiny >>

If you pass configurations to import:

    use Path::FindDev find_dev => { set => $someset };

Then the exported C<find_dev> will pass that set name to L<< C<Path::IsDev>|Path::IsDev >>.

Though you should only do this if

=over 4

=item * the default set is inadequate for your usage

=item * you don't want the set to be overridden by C<%ENV>

=back

Additionally, you can call find_dev directly:

    require Path::FindDev;

    my $result = Path::FindDev::find_dev('/some/path');

Which by design inhibits your capacity to specify an alternative set in code.

=cut

*find_dev = _build_find_dev( __PACKAGE__, 'find_dev', {} );

1;
