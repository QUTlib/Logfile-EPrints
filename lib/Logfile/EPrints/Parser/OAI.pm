package Logfile::EPrints::Parser::OAI;

=head1 NAME

Logfile::EPrints::Parser::OAI - Parse hits from an OAI-PMH interface

=head1 METHODS

=over 4

=cut

use strict;
use warnings;

use HTTP::OAI;

=item new( baseURL => <baseURL>, handler => <handler> )

Create a new object to query <baseURL>

=cut

sub new
{
	my( $class, %args ) = @_;
	bless \%args, $class;
}

sub baseurl { shift->{ baseURL }}
sub agent { shift->{ agent }}
sub response { shift->{ response }}

=item $h->harvest(@opts)

Harvest all records from the OAI server, @opts are any OAI arguments (e.g. use 'from' to specify a datestamp to start from). Defaults to using 'context_object' as the metadata prefix.

The service type given is called on the handler (abstract, citation, fulltext etc.).

=cut

sub harvest
{
	my $self = shift;
	my $handler = $self->{ handler } or return;
	my $h = $self->{ agent } = HTTP::OAI::Harvester->new( baseURL => $self->baseurl );
	my $r = $self->{ response } = $h->ListRecords(
		metadataPrefix => 'context_object',
		handlers => {
			metadata => 'Logfile::EPrints::Hit::ContextObject'
		},
		@_,
	);
	die $r->message unless $r->is_success;
	while(my $rec = $r->next)
	{
		my $hit = $rec->metadata;
		my $f = $hit->{ svc };
		$handler->$f( $hit );
	}
	die $r->message unless $r->is_success;
}

=back

=cut

package Logfile::EPrints::Hit::ContextObject;

use strict;
use warnings;

use Data::Dumper;
use Carp;
use HTTP::OAI::Metadata;
use Logfile::EPrints::Hit;
use vars qw( @ISA );
@ISA = qw( HTTP::OAI::Metadata Logfile::EPrints::Hit::Combined );

sub new
{
	return bless {entity => ''}, shift;
}
sub entity { shift->{ 'entity' }};
sub service { shift->{ 'svc' }};

# Logfile accessors
sub date { shift->{ 'date' }};
sub agent { shift->{ 'requester' }->{ 'private-data' }};
sub identifier { shift->{ 'referent' }->{ 'identifier' }}

sub address
{
	substr(shift->{ 'requester' }->{ 'identifier' },7); # strip urn:ip:
}

sub start_element
{
	my( $self, $hash ) = @_;
	my $n = $hash->{ LocalName };
	if( $n eq 'context-object' )
	{
		$self->{ date } = $hash->{ Attributes }->{ '{}timestamp' }->{ Value };
	}
	elsif( $n =~ /^referent|referring-entity|requester|service-type$/ )
	{
		$self->{ 'entity' } = $n;
	}
	elsif( $n eq 'svc-list' )
	{
		$self->{ 'in_svc' } = 1;
	}
}

sub end_element
{
	my( $self, $hash ) = @_;
	my $n = $hash->{ LocalName };
	if( $n eq $self->entity )
	{
		$self->{ 'entity' } = '';
		return;
	}
	if( $n =~ /^identifier|private-data$/ )
	{
		$self->{$self->entity}->{$n} = $hash->{ Text };
	}
	elsif( 'svc-list' eq $n )
	{
		$self->{ 'in_svc' } = 0;
	}
	elsif( $self->{ 'in_svc' } )
	{
		$self->{ 'svc' } = $n if $hash->{ Text } eq 'yes';
	}
}

sub end_document
{
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
