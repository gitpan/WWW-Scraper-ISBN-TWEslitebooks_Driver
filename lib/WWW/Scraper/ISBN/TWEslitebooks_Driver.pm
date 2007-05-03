# ex:ts=8

package WWW::Scraper::ISBN::TWEslitebooks_Driver;

use strict;
use warnings;

use vars qw($VERSION @ISA);
$VERSION = '0.02';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::TWEslitebooks_Driver - Search driver for TWEslitebooks' online catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the TWEslitebooks' online catalog.

=cut

#--------------------------------------------------------------------------

###########################################################################
#Library Modules                                                          #
###########################################################################

use WWW::Scraper::ISBN::Driver;
use WWW::Mechanize;
use Template::Extract;
use Text::Iconv;

###########################################################################
#Constants                                                                #
###########################################################################

use constant	ESLITEBOOKS	=> 'http://www.eslitebooks.com';

#--------------------------------------------------------------------------

###########################################################################
#Inheritence                                                              #
###########################################################################

@ISA = qw(WWW::Scraper::ISBN::Driver);

###########################################################################
#Interface Functions                                                      #
###########################################################################

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the Eslitebooks
server.

The returned page should be the correct catalog page for that ISBN. If not the
function returns zero and allows the next driver in the chain to have a go. If
a valid page is returned, the following fields are returned via the book hash:

  isbn
  ean
  title
  author
  pages
  book_link
  image_link
  pubdate
  publisher
  price_list
  price_sell

The book_link and image_link refer back to the Eslitebooks website. 

=back

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $mechanize = WWW::Mechanize->new();
	$mechanize->get(ESLITEBOOKS);

	$mechanize->submit_form(
		form_name	=> 'frmbas',
		fields		=> {
			query	=> $isbn,
		},
	);

	my $book_link = $mechanize->uri;

	my $conv = Text::Iconv->new("utf-8", "big5");
	my $content = $mechanize->content();
	$content =~ /(<td valign="middle" align="center" height="180" style="border-bottom: #a0a882.*meta)/s;
	$content = $conv->convert($1);

	my $template = <<END;
<td valign="middle" align="center" height="180" style="border-bottom: #a0a882 [% ... %]
<img hspace="5" src="[% image_link %]" [% ... %]
<iframe src='[% iframe %]'[% ... %]
s10lh14ls1b'>[% title %]</div>[% ... %]
s9lh14ls1>作者／[% ... %]>[% author %]<[% ... %]
出版社／[% ... %]>[% publisher %]<[% ... %]
出版日期／ [% pubdate %]<[% ... %]
EAN／[% ean %]<br>[% ... %]
頁數／[% pages %]<br>
END

	my $extract = Template::Extract->new;
	my $data = $extract->extract($template, $content);

	return $self->handler("Could not extract data from TWEslitebooks result page.")
		unless(defined $data);

	$mechanize->get($data->{iframe});

	my $tmp = $conv->convert($mechanize->content());
	$tmp =~ /定價.*>(\d+).*網路價.*>(\d+)/s;
	my ($price_list, $price_sell) = ($1, $2);

	my $bk = {
		'isbn'		=> $isbn,
		'ean'		=> $data->{ean},
		'title'		=> $data->{title},
		'author'	=> $data->{author},
		'pages'		=> $data->{pages},
		'book_link'	=> "$book_link",
		'image_link'	=> ESLITEBOOKS.$data->{image_link},
		'pubdate'	=> $data->{pubdate},
		'publisher'	=> $data->{publisher},
		'price_list'	=> $price_list,
		'price_sell'	=> $price_sell,
	};

	$self->book($bk);
	$self->found(1);
	return $self->book;
}

1;
__END__

=head1 REQUIRES

Requires the following modules be installed:

L<WWW::Scraper::ISBN::Driver>,
L<WWW::Mechanize>,
L<Template::Extract>

=head1 SEE ALSO

L<WWW::Scraper::ISBN>,
L<WWW::Scraper::ISBN::Record>,
L<WWW::Scraper::ISBN::Driver>

=head1 AUTHOR

Ying-Chieh Liao E<lt>ijliao@csie.nctu.edu.twE<gt>

=head1 COPYRIGHT

Copyright (C) 2005 Ying-Chieh Liao E<lt>ijliao@csie.nctu.edu.twE<gt>

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
