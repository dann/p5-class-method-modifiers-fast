use inc::Module::Install;
name 'Class-Method-Modifiers-Fast';
all_from 'lib/Class/Method/Modifiers/Fast.pm';

requires $_ for (qw/ /);

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
