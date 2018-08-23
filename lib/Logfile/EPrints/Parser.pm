package Logfile::EPrints::Parser;

use Logfile::EPrints::Hit;
use POSIX qw/strftime/;

use strict;

sub new
{
	my ($class,%args) = @_;
	$args{type} ||= $args{parser};
	$args{type} ||= 'Logfile::EPrints::Hit::Combined';
	bless \%args, $class;
}

sub parse_fh
{
	my ($self,$fh) = @_;
	return unless my $handler = $self->{handler};

	my $hit;
	my $hit_class = $self->{type};
	while(<$fh>)
	{
		chomp($_);
		if( defined($hit = $hit_class->new($_)) ) {
			$handler->hit($hit);
		}
		else {
			Carp::carp("Error parsing: $_");
		}
	}
}

1;

=pod

=head1 NAME

Logfile::EPrints::Parser - Parse Web server logs that are formatted as one hit per line (e.g. Apache)

=head1 SYNOPSIS

	use Logfile::EPrints::Parser;

	$p = Logfile::EPrints::Parser->new(
	  type=>'Logfile::EPrints::Hit::Combined',
	  handler=>$Handler
	);

	open my $fh, "<access_log" or die $!;
	$p->parse_fh($fh);
	close($fh);

=head1 METHODS

=over 4

=item new()

Create a new Logfile::Parser object with the following options:

	type - Optionally specify a class to parse log file lines with (defaults to ::CombinedLog)
	handler - Handler to call (see HANDLER CALLBACKS)

=back
	
=head1 HANDLER CALLBACKS

=over 4

=item hit()

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Timothy D Brody

Copyright (C) 2018, Matthew Kerwin and Queensland University of Technology

This file is part of Logfile::EPrints-bis

Logfile::EPrints-bis is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Logfile::EPrints-bis is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Logfile::EPrints-bis. If not, see https://www.gnu.org/licenses/.

=cut
