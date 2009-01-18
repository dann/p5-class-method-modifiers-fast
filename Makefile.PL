use inc::Module::Install;
name 'Class-Method-Modifiers-Fast';
all_from 'lib/Class/Method/Modifiers/Fast.pm';

requires       'Data::Util';

build_requires 'Test::More';
build_requires 'Test::Exception';

use_test_base;
auto_include;
WriteAll;
