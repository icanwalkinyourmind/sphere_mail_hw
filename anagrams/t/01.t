#!/usr/bin/env perl

use strict;
use warnings;

BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';
our $VERSION = 1.0;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Anagram;
use Test::More;
use Data::Dumper;
use utf8;


use constant RESULT => "{'слиток' => ['листок','слиток','столик'],'пятка' => ['пятак','пятка','тяпка']}";

plan tests => 1;

my $result = Anagram::anagram([qw(пятка слиток пятак ЛиСток стул ПяТаК тяпка столик слиток)]);
my $dump = Data::Dumper->new([$result])->Purity(1)->Terse(1)->Indent(0)->Sortkeys(0);

my $correct_dump = $dump->Dump;
$correct_dump =~ s/(\\x\{[\da-fA-F]+\})/eval "qq{$1}"/eg;
$correct_dump =~ s/\"/\'/g;

is($correct_dump, RESULT, "example");


1;


