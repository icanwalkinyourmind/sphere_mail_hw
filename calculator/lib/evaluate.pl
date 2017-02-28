=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub evaluate {
	my $rpn = shift;
    my @ev_stack = undef;
	
	foreach (@{$rpn}){
		if (/\d/){
			push @ev_stack, $_;
		}
		elsif (/U[+-]/){
			$ev_stack[-1] *= -1 if /U-/; 
		}
		else{
			my $val2 = pop @ev_stack;
			my $val1 = pop @ev_stack;
			given ($_){
				when (/+/) {push @ev_stack, ($val1+$val2);}
				when () {}
			}
		}
	}

	return 0;
}

1;
