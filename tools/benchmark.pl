#!/usr/bin/env perl

use FindBin::libs;
use Benchmark qw(cmpthese);
use Benchmark ':hireswallclock';

### MODULES

{

    package PlainParent;
    sub new { bless {} => shift }
    sub method {"P"}
}

{

    package MooseParent;
    use Moose;
    sub method {"P"}
}

## before
{

    package CMMChild::Before;
    use Class::Method::Modifiers;
    use base 'PlainParent';

    before method => sub {"B"};
}

{

    package CMMFChild::Before;
    use Class::Method::Modifiers::Fast;
    use base 'PlainParent';

    before method => sub {"B"};
}

{

    package MooseBefore;
    use Moose;
    extends 'MooseParent';

    before method => sub {"B"};
}

## after
{

    package CMMChild::After;
    use Class::Method::Modifiers;
    use base 'PlainParent';

    after method => sub {"B"};
}

{

    package CMMFChild::After;
    use Class::Method::Modifiers::Fast;
    use base 'PlainParent';

    after method => sub {"B"};
}

{

    package MooseAfter;
    use Moose;
    extends 'MooseParent';

    after method => sub {"B"};
}

## around
{

    package CMMChild::Around;
    use Class::Method::Modifiers;
    use base 'PlainParent';

    around method => sub { shift->() . "A" };
}
{

    package CMMFChild::Around;
    use Class::Method::Modifiers::Fast;
    use base 'PlainParent';

    around method => sub { shift->() . "A" };
}
{

    package MooseAround;
    use Moose;
    extends 'MooseParent';

    around method => sub { shift->() . "A" };
}

# AllThree
{

    package CMMChild::AllThree;
    use Class::Method::Modifiers;
    use base 'PlainParent';

    before method => sub {"B"};
    around method => sub { shift->() . "A" };
    after method  => sub {"Z"};
}
{

    package CMMFChild::AllThree;
    use Class::Method::Modifiers::Fast;
    use base 'PlainParent';

    before method => sub {"B"};
    around method => sub { shift->() . "A" };
    after method  => sub {"Z"};
}
{

    package MooseAllThree;
    use Moose;
    extends 'MooseParent';

    before method => sub {"B"};
    around method => sub { shift->() . "A" };
    after method  => sub {"Z"};
}
{

    package CMM::Install;
    use Class::Method::Modifiers;
    use base 'PlainParent';
}
{

    package CMMF::Install;
    use Class::Method::Modifiers::Fast;
    use base 'PlainParent';
}
{

    package Moose::Install;
    use Moose;
    extends 'MooseParent';
}

my $rounds = -5;

my $cmm_before   = CMMChild::Before->new();
my $cmm_after    = CMMChild::After->new();
my $cmm_around   = CMMChild::Around->new();
my $cmm_allthree = CMMChild::AllThree->new();

my $cmmf_before   = CMMFChild::Before->new();
my $cmmf_after    = CMMFChild::After->new();
my $cmmf_around   = CMMFChild::Around->new();
my $cmmf_allthree = CMMFChild::AllThree->new();

my $moose_before   = MooseBefore->new();
my $moose_after    = MooseAfter->new();
my $moose_around   = MooseAround->new();
my $moose_allthree = MooseAllThree->new();

print "\nBEFORE\n";
cmpthese(
    $rounds,
    {   Moose                    => sub { $moose_before->method() },
        ClassMethodModifiers     => sub { $cmm_before->method() },
        ClassMethodModifiersFast => sub { $cmmf_before->method() },
    },
    'noc'
);

print "\nAFTER\n";
cmpthese(
    $rounds,
    {   Moose                    => sub { $moose_after->method() },
        ClassMethodModifiers     => sub { $cmm_after->method() },
        ClassMethodModifiersFast => sub { $cmmf_after->method() },
    },
    'noc'
);

print "\nAROUND\n";
cmpthese(
    $rounds,
    {   Moose                    => sub { $moose_around->method() },
        ClassMethodModifiers     => sub { $cmm_around->method() },
        ClassMethodModifiersFast => sub { $cmmf_around->method() },
    },
    'noc'
);

print "\nALL THREE\n";
cmpthese(
    $rounds,
    {   Moose                    => sub { $moose_allthree->method() },
        ClassMethodModifiers     => sub { $cmm_allthree->method() },
        ClassMethodModifiersFast => sub { $cmmf_allthree->method() },
    },
    'noc'
);

print "\nINSTALL AROUND\n";
cmpthese(
    $rounds,
    {   Moose => sub {

            package Moose::Install;
            Moose::Install::around( method => sub { } );
        },
        ClassMethodModifiers => sub {

            package CMM::Install;
            CMM::Install::around( method => sub { } );
        },
        ClassMethodModifiersFast => sub {

            package CMMF::Install;
            CMM::Install::around( method => sub { } );
        },
    },
    'noc'
);

