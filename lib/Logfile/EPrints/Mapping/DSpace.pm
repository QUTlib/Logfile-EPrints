package Logfile::EPrints::Mapping::DSpace;

use strict;
use warnings;

=head1 NAME

Logfile::EPrints::Mapping::DSpace - Map DSpace logs to requests

=head1 SYNOPSIS

See L<Logfile::EPrints>.

	use Logfile::EPrints;

	my $parser = Logfile::EPrints::Parser->new(
		handler => Logfile::EPrints::Mapping::DSpace->new(
		identifier => 'oai:dspace:',
		handler => MyHandler->new
	));

	$parser->parse_fh( $fh );

=head1 CAVEATS

This module only supports abstract and fulltext.

DSpace uses the exact same URL layout for communities as it does papers, so there's no way to distinguish them from just the log files. Community hits therefore come out as 'abstract' hits.

=cut

sub new
{
	my( $class, %self ) = @_;

	Carp::croak(__PACKAGE__." requires identifier argument") unless exists $self{identifier};

	bless \%self, $class;
}

sub hit
{
	my( $self, $hit ) = @_;

	my $page = $hit->page;

	if( not defined $page )
	{
		warn "Hmm, error parsing hit - no page request found in: ".$hit->raw."\n";
	}
	# Abstract or community page
	elsif( $page =~ /\/handle\/(\d+)\/(\d+)$/ )
	{
		$hit->{identifier} = $self->_identifier( $1, $2 );
		$self->{handler}->abstract( $hit );
	}
	# Bitstream /dspace/bitstream/2160/229/1/Holocene+environments+faynan.pdf
	elsif( $page =~ /\/bitstream\/(\d+)\/(\d+)\/(\d+)\// )
	{
		$hit->{identifier} = $self->_identifier( $1, $2 );
		$self->{handler}->fulltext( $hit );
	}
	# Browse /dspace/browse-date?top=2160%2F161
#	elsif( $page =~ /\/browse-(\w+)(?:\?|$)/ )
#	{
#	}
	# Items-by /dspace/items-by-author?author=Pearce%2C+Jake&order=date
#	elsif( $page =~ /\/items-by-(\w+)(?:\?|$)/ )
#	{
#	}
	# Feedback /dspace/feedback?fromPage=http%3A%2F%2Fcadair.aber.ac.uk%2Fdspace%2Fbrowse-title%3Fstarts_with%3DI
#	elsif( $page =~ /\/feedback\?/ )
#	{
#	}
	# static /dspace/image/arrow.gif
#	elsif( $page =~ /\/image\/([^\/]+)$/ or $page =~ /styles.css.jsp|robots.txt|utils.js$/ )
#	{
#	}
#	else
#	{
#		print STDERR "Unhandled hit: ".$hit->raw."\n";
#	}
}

sub _identifier
{
	my( $self, $repo, $item ) = @_;

	return $self->{identifier} . "$repo/$item";
}

1;

__END__

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Timothy D Brody

Copyright (C) 2018, Matthew Kerwin and Queensland University of Technology

This file is part of Logfile::EPrints-bis

Logfile::EPrints-bis is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Logfile::EPrints-bis is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Logfile::EPrints-bis. If not, see https://www.gnu.org/licenses/.

=cut
