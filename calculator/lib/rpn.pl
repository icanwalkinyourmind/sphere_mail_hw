=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @rpn;
	my @op_stack = ();
	my $op_symbols = '\+ \- \* \/';
	my %op_priority = (
					'U+' => 4, 'U-' => 4,
					'^' => 3,
					'*' => 2, '/' => 2,
					'+' => 1, '-' => 1,
					'(' => 0, ')' =>0,
				   );
	foreach (@{$source}){
		given ($_){
			when (/\d/) {push @rpn, $_}
			when (/\(/) {push @op_stack, $_}	
			when (/\)/) {
				until ($op_stack[-1] eq '('){
					push @rpn, pop @op_stack;
				}
				pop @op_stack;
			}
			when (/[$op_symbols\^]|(U[+-])/) {
				my $mark = '';
				until ($mark eq 'end'){
					unless (@op_stack) {push @op_stack, $_; continue}
					#правоассоциативный
					if (/\^|(U[+-])/ and $op_stack[-1] =~ /[$op_symbols]/) {
						if ($op_priority{$_} < $op_priority{ $op_stack[-1] }) {
							push @rpn, pop @op_stack;
						}
						else{
							push @op_stack, $_;
							$mark = 'end';
						}
					}
					#левоассоциативный
					else{
						if ($op_priority{$_} <= $op_priority{ $op_stack[-1] }) {
							push @rpn, pop @op_stack;							
						}
						else{
							push @op_stack, $_;
							$mark = 'end';
						}
					}
				}
			}	
		}
	}
	
	for (reverse @op_stack) {
		die "wrong expr" if (/\( \) [^$op_symbols]/x);
		push @rpn, $_;
	}

	return \@rpn;
}

1;
