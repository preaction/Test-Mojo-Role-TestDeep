package Test::Mojo::Role::TestDeep;
# ABSTRACT: Add Test::Deep methods to Test::Mojo::WithRoles

=head1 SYNOPSIS

    use Test::Deep;
    use Test::Mojo::WithRoles 'TestDeep';

    my $t = Test::Mojo->new( 'MyApp' );
    $t->get_ok( '/data.json' )
        ->json_deeply(
            superhashof( { foo => 'bar' } ),
            'has at least a foo key with "bar" value',
        );

=head1 DESCRIPTION

This module adds some L<Test::Deep> functionality to L<Test::Mojo>. C<Test::Deep>
allows for extremely-customizable testing of data structures.

=cut

use strict;
use warnings;
use Role::Tiny;
use Test::Deep qw( cmp_deeply );

=method json_deeply

    $t->cmp_deeply( $expect, $desc )
    $t->cmp_deeply( $ptr, $expect, $desc )

Test that the current response (parsed as a JSON object) matches the given
tests. C<$expect> is a data structure containing L<Test::Deep
comparisons|SPECIAL COMPARISONS PROVIDED> to run. C<$desc> is a description of
the test.

If given, C<$ptr> is a JSON pointer string to pick out a single part of the
data structure. This is more convenient than using Test::Deep's comparison
routines to do the same thing. See L<Mojo::JSON::Pointer>.

Corresponds to L<cmp_deeply in Test::Deep|Test::Deep/COMPARISON FUNCTIONS>.

=cut

sub json_deeply {
    my ( $t, $ptr, $expect, $desc ) = @_;

    # Pointer is an optional argument
    if ( @_ < 4 && !ref $expect ) {
        $desc = $expect;
        $expect = $ptr;
        $ptr = '';
    }

    die "expected value should be a data structure or Test::Deep test object, not a simple scalar (did you mean to use json_is()?)"
        if !ref $expect;

    $desc ||= qq{deeply match JSON Pointer "$ptr"};

    my $given = $t->tx->res->json( $ptr );

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return $t->success( cmp_deeply( $given, $expect, $desc ) );
}

1;

__END__

=head1 SEE ALSO

=over 4

=item L<Test::Deep>

=item L<Test::Mojo>

=item L<Test::Mojo::WithRoles>

=back

