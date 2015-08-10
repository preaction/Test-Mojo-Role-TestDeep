
use strict;
use warnings;
use Test::More;
use Test::Exception;

{
    package MyApp;
    use Mojo::Base 'Mojolicious';

    sub startup {
        my ( $app ) = @_;
        my $r = $app->routes;
        $r->get( '/data.json' )
          ->to( cb => sub {
            $_[0]->render(
                json => {
                    foo => [ 1, 2, 3 ],
                    bar => {
                        baz => [ 7, 8, 9 ]
                    }
                }
            );
        } );
    }
}

use Test::Mojo::WithRoles 'TestDeep';
use Test::Deep;
use Scalar::Util qw( refaddr );
my $t = Test::Mojo::WithRoles->new( 'MyApp' );

ok $t->can( 'json_deeply' ), 'the method was installed';

subtest 'one-arg: test only' => sub {
    my $test = {
        foo => bag( 3, 2, 1 ),
        bar => superhashof({
            baz => bag( 9, 8, 7 ),
        }),
    };

    my $retval = $t->get_ok( '/data.json' )->json_deeply( $test );
    is refaddr $retval, refaddr $t;
    ok $t->success, 'last test was successful';
};

subtest 'two-arg with reference first: test with description' => sub {
    my $test = {
        foo => bag( 3, 2, 1 ),
        bar => superhashof({
            baz => bag( 9, 8, 7 ),
        }),
    };

    my $retval = $t->get_ok( '/data.json' )->json_deeply( $test, 'description' );
    is refaddr $retval, refaddr $t;
    ok $t->success, 'last test was successful';
};

subtest 'two-arg with reference second: json pointer' => sub {
    my $test = bag( 3, 2, 1 );
    my $retval = $t->get_ok( '/data.json' )->json_deeply( '/foo' => $test );
    is refaddr $retval, refaddr $t;
    ok $t->success, 'last test was successful';
};

subtest 'two-arg without reference: error, ambiguous' => sub {
    throws_ok { $t->get_ok( '/data.json' )->json_deeply( '/foo/0' => 1 ) }
        qr{\Qexpected value should be a data structure or Test::Deep test object, not a simple scalar (did you mean to use json_is()?)};
};

subtest 'three-arg: json pointer and desc' => sub {
    my $test = bag( 3, 2, 1 );
    my $retval = $t->get_ok( '/data.json' )->json_deeply( '/foo' => $test, 'description' );
    is refaddr $retval, refaddr $t;
    ok $t->success, 'last test was successful';
};

done_testing;
