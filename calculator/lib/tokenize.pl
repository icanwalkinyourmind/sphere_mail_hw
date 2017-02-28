=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

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

sub tokenize {
	chomp(my $expr = shift);
	my @res;
	my $symbols = '\+ \- \* \^ \( \) \/';
	my $uno = 'U[+-]';
	
	#удаляем пропуски, расставляем унарыне операции
	$expr =~ s/\s//g;
	$expr =~ s/^([+-])/U$1/g;
	my $old_expr = '';
	until ($expr eq $old_expr ){
		$old_expr = $expr;
		$expr =~ s/ ([$symbols] | $uno)([+-]) /${1}U${2}/xg;
	}
	
	#проверяем валидность выражения
	given ($expr){
		when (/[^ $symbols \d U E e \.]/x) {die "wrong expr"; continue}
		when (/ ^[$symbols]+$ | ^[^$symbols]{2,}$ | ^($uno)+$ /x) {die "wrong expr"}
		when (/($uno)[\^ \* \/]/x) {die "Bin after uno"}
	}
	
	#разбиваем на токены
	@res = grep /\S/, split /([$symbols] | U[+-] | \d?\.?\d[Ee][+-]?\d)/x, $expr;
	#для тестов
	@res = map {if (/\d/) {$_*=1; "$_"} else {$_} } @res;
	return \@res;
}

1;
