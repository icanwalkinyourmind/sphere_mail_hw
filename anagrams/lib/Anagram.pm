package Anagram;

use 5.010;
use strict;
use warnings;
use DDP;
use Data::Dumper;
use Encode;
use utf8;
use Text::Unidecode;

=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut

sub anagram {
    my $words_list = shift;
    my %result;
    my %matched;
    foreach my $word (@{$words_list}) {
        $word =~ s/(\w)/\l$1/g;
        for (keys %result){
            if (/^[$word]+$/ and not defined $matched{$word}){
                push @{$result{$_}}, $word;
                $matched{$word} = 'yes';
            }
        }
        unless (defined $matched{$word}){
            $result{$word} = [$word];
            $matched{$word} = 'yes';
        }
    }
    
    for (keys %result){
       	if (not defined $result{$_}->[1]){
	    delete $result{$_};
	}
	else{
	   @{$result{$_}} = sort {$a cmp $b} @{$result{$_}};
	}
    }
    
    return \%result;
}

my $result = Anagram::anagram([qw(пятка слиток пятак ЛиСток стул ПяТаК тяпка столик слиток)]);
my $dump = Data::Dumper->new([$result])->Purity(1)->Terse(1)->Indent(0)->Sortkeys(0);

1;