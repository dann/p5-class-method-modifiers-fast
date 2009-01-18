#!perl -T
use strict;
use warnings;
use Test::More qw/no_plan/;
use Carp;

# another test file stolen from Class::MOP

# no need to bring in Test::Exception .. >_>
sub lives_ok (&$)
{
    my ($code, $name) = @_;

    eval { $code->() };
    ok(!$@, $name);
}

sub dies_ok (&$)
{
    my ($code, $name) = @_;

    eval { $code->() };
    ok($@, $name);
}

{
    package BankAccount;
    
    use strict;
    use warnings;
 
    sub new {
        my $class = shift;
        my $self = {};
        bless $self, $class;
        $self->BUILD(@_);
        return $self;
    }

    sub BUILD {
        my $self = shift;
        my %args = @_;
        $self->{balance} = delete $args{balance} || 0;
    }

    sub balance {
        my $self = shift;
        $self->{balance} = shift if @_;
        return $self->{balance};
    }

    sub deposit {
        my ($self, $amount) = @_;
        $self->balance($self->balance + $amount);
    }
    
    sub withdraw {
        my ($self, $amount) = @_;
        my $current_balance = $self->balance();
        ($current_balance >= $amount)
            || Carp::confess "Account overdrawn";
        $self->balance($current_balance - $amount);
    }

	package CheckingAccount;

	use strict;
	use warnings;
	our @ISA = 'BankAccount';
    use Class::Method::Modifiers::Fast;
	
    sub BUILD {
        my $self = shift;
        my %args = @_;
        $self->{overdraft_account} = delete $args{overdraft} || 0;
        $self->SUPER::BUILD(%args);
    }

    sub overdraft_account {
        my $self = shift;
        $self->{overdraft_account} = shift if @_;
        return $self->{overdraft_account};
    }

    before 'withdraw' => sub {
		my ($self, $amount) = @_;
		my $overdraft_amount = $amount - $self->balance();
		if ($overdraft_amount > 0) {
			$self->overdraft_account->withdraw($overdraft_amount);
			$self->deposit($overdraft_amount);
		}
    };
}

my $savings_account = BankAccount->new(balance => 250);
isa_ok($savings_account, 'BankAccount');

is($savings_account->balance, 250, '... got the right savings balance');
lives_ok {
	$savings_account->withdraw(50);
} '... withdrew from savings successfully';
is($savings_account->balance, 200, '... got the right savings balance after withdrawl');
dies_ok {
	$savings_account->withdraw(250);
} '... could not withdraw from savings successfully';


$savings_account->deposit(150);
is($savings_account->balance, 350, '... got the right savings balance after deposit');

my $checking_account = CheckingAccount->new(
							balance   => 100,
							overdraft => $savings_account
						);
isa_ok($checking_account, 'CheckingAccount');
isa_ok($checking_account, 'BankAccount');

is($checking_account->overdraft_account, $savings_account, '... got the right overdraft account');

is($checking_account->balance, 100, '... got the right checkings balance');

lives_ok {
	$checking_account->withdraw(50);
} '... withdrew from checking successfully';
is($checking_account->balance, 50, '... got the right checkings balance after withdrawl');
is($savings_account->balance, 350, '... got the right savings balance after checking withdrawl (no overdraft)');

lives_ok {
	$checking_account->withdraw(200);
} '... withdrew from checking successfully';
is($checking_account->balance, 0, '... got the right checkings balance after withdrawl');
is($savings_account->balance, 200, '... got the right savings balance after overdraft withdrawl');

