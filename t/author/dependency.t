use Test::Dependencies
	exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic Class::Method::Modifiers::Fast/],
	style   => 'light';
ok_dependencies();
