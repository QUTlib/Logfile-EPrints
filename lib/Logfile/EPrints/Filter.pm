package Logfile::EPrints::Filter;

=head1 NAME

Logfile::EPrints::Filter - base class for filters

=head1 SYNOPSIS

A minimal filter that removes all abstract requests:

	package Logfile::EPrints::Filter::Custom;

	our @ISA = qw( Logfile::EPrints::Filter );

	sub abstract {}

	1;

=cut

use strict;

use vars qw( $AUTOLOAD );

sub new
{
	my( $class, %self ) = @_;
	bless \%self, $class;
}

sub AUTOLOAD
{
	return if $AUTOLOAD =~ /[A-Z]$/;
	$AUTOLOAD =~ s/^.*:://;
	$_[0]->{handler}->$AUTOLOAD( $_[1] );
}

package Logfile::EPrints::Filter::Debug;

use strict;

use vars qw( $AUTOLOAD );

our @ISA = qw( Logfile::EPrints::Filter );

sub AUTOLOAD
{
	return if $AUTOLOAD =~ /[A-Z]$/;
	$AUTOLOAD =~ s/^.*:://;
	my( $self, $hit ) = @_;
	$self->{requests}->{$AUTOLOAD}++;
	for( sort keys(%{$self->{requests}}) ) {
		print STDERR "+" if $_ eq $AUTOLOAD;
		print STDERR "$_ [".$self->{requests}->{$_}."] ";
	}
	print STDERR "\r";
	$self->{handler}->$AUTOLOAD( $hit );
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
