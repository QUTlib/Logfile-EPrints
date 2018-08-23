package Logfile::EPrints::Filter::Period;

use vars qw( $AUTOLOAD );

sub new {
	my ($class,%self) = @_;
	bless \%self, ref($class) || $class;
}

sub AUTOLOAD
{
	$AUTOLOAD =~ s/^.*:://;
	return if $AUTOLOAD =~ /[A-Z]$/;
	my ($self,$hit) = @_;
	return if defined($self->{after}) && $hit->datetime <= $self->{after};
	return if defined($self->{before}) && $hit->datetime >= $self->{before};
	$self->{handler}->$AUTOLOAD($hit);
}

1;

=pod

=head1 NAME

Logfile::EPrints::Filter::Period

=head1 DESCRIPTION

Filter hits for a given time period (given as yyyymmddHHMMSS).

=head1 METHODS

=over 5

=item new(%opts)

	after=>20040320145959
		only include records I<after> this datetime
	before=>20040320160000
		only include records I<before> this datetime

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Timothy D Brody

Copyright (C) 2018, Matthew Kerwin and Queensland University of Technology

This file is part of Logfile::EPrints-bis

Logfile::EPrints-bis is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Logfile::EPrints-bis is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Logfile::EPrints-bis. If not, see https://www.gnu.org/licenses/.

=cut
