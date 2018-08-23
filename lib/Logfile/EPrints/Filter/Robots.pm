package Logfile::EPrints::Filter::Robots;

use strict;
use warnings;

use Carp;

use vars qw( $AUTOLOAD %KNOWN_AGENTS );

use lib '/var/www/awstats/lib'; # DAG
use lib '/usr/share/awstats/lib'; # Fedora Core

my $r = do "robots.pm";
$r = do "search_engines.pm" if $r;
unless( defined $r )
{
	Carp::confess "Error loading awstats, you may need to include it's library path before use()ing ".__PACKAGE__.": $!";
}

our @RobotsSearchIDOrder = ();
{
	no strict "refs";
	for(qw( list1 list2 listgen ))
	{
		push @RobotsSearchIDOrder, @{"RobotsSearchIDOrder_$_"};
	}
}
$_ = qr/$_/i for @RobotsSearchIDOrder;
unless( scalar @RobotsSearchIDOrder )
{
	Carp::confess "We appear to have loaded awstats, but didn't get any robots records from robots.pm/search_engines.pm?";
}

sub new
{
	my ($class,%args) = @_;
	bless \%args, ref($class) || $class;
}

sub AUTOLOAD
{
	return if $AUTOLOAD =~ /[A-Z]$/;
	$AUTOLOAD =~ s/^.*:://;
	my( $self, $hit ) = @_;
	my $UserAgent = $hit->agent
		or return $self->{handler}->$AUTOLOAD($hit);
	if( exists $KNOWN_AGENTS{ $UserAgent } )
	{
		return $KNOWN_AGENTS{ $UserAgent } ?
			undef :
			$self->{handler}->$AUTOLOAD($hit);
	}
	for(@RobotsSearchIDOrder)
	{
		if( $UserAgent =~ /$_/ )
		{
			$KNOWN_AGENTS{ $UserAgent } = 1;
			return undef;
		}
	}
	$KNOWN_AGENTS{ $UserAgent } = 0;
	return $self->{handler}->$AUTOLOAD($hit);
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
