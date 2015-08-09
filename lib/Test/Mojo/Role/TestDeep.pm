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

sub json_deeply {
    my ( $t, $test, $desc ) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return cmp_deeply( $t->tx->res->json, $test, $desc );
}

1;

__END__

=head1 SEE ALSO

=over 4

=item L<Test::Deep>

=item L<Test::Mojo>

=item L<Test::Mojo::WithRoles>

=back

