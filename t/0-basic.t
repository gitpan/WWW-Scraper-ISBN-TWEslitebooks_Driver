#!/usr/bin/env perl

use strict;
use Test::More tests => 15;

use_ok('WWW::Scraper::ISBN::TWEslitebooks_Driver');

ok($WWW::Scraper::ISBN::TWEslitebooks_Driver::VERSION) if $WWW::Scraper::ISBN::TWEslitebooks_Driver::VERSION or 1;

use WWW::Scraper::ISBN;
my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

$scraper->drivers("TWEslitebooks");
my $isbn = "9864175351";
my $record = $scraper->search($isbn);

SKIP: {
	skip($record->error."\n", 12) unless($record->found);

	is($record->found, 1);
	is($record->found_in, 'TWEslitebooks');

	my $book = $record->book;
	is($book->{'isbn'}, '9864175351');
	is($book->{'ean'}, '9789864175352');
	is($book->{'title'}, '�Ů�����: �}�еL�H�v�������s����');
	like($book->{'author'}, qr/������/);
	is($book->{'pages'}, '376');
	is($book->{'book_link'}, 'http://www.eslitebooks.com/cgi-bin/eslite.dll/add_cart/cart_frm_calculate.jsp?PRODUCT_ID=2611393953002&cartType=book');
	is($book->{'image_link'}, 'http://www.eslitebooks.com/EsliteBooks/book/picture/M/2910486972006.jpg');
	is($book->{'pubdate'}, '20050805');
	is($book->{'publisher'}, '�ѤU�����X���ѥ��������q');
	is($book->{'price_list'}, '450');
}
