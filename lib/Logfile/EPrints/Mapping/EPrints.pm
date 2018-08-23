package Logfile::EPrints::Mapping::EPrints;

use strict;
use warnings;

sub new {
	my ($class,%self) = @_;

	Carp::croak(__PACKAGE__." requires identifier argument") unless exists $self{identifier};

	bless \%self, $class;
}

sub hit {
	my ($self,$hit) = @_;
	if( 'GET' eq $hit->method && 200 == $hit->code ) {
		my $path = URI->new($hit->page,'http')->path;
		# Full text
		if( $path =~ /^(?:\/archive)?\/(\d+)\/\d/ ) {
			$hit->{identifier} = $self->_identifier($1);
			$self->{handler}->fulltext($hit);
		} elsif( $path =~ /^(?:\/archive)?\/(\d+)\/?$/ ) {
			$hit->{identifier} = $self->_identifier($1);
			$self->{handler}->abstract($hit);
		} elsif( $path =~ /^\/view\/(\w+)\// ) {
			$hit->{section} = $1;
			$self->{handler}->browse($hit);
		} elsif( $path =~ /^\/perl\/search/ ) {
			$self->{handler}->search($hit);
		} else {
			#warn "Unknown path = ", $uri->path, "\n";
		}
	}
}

sub _identifier {
	my ($self,$no) = @_;
	return $self->{'identifier'}.($no+0);
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Logfile::EPrints::Mapping::EPrints - Parse Apache logs from GNU EPrints

=head1 SYNOPSIS

  use Logfile::EPrints;

  my $parser = Logfile::EPrints::Parser->new(
	handler=>Logfile::EPrints::Mapping::EPrints->new(
	  identifier=>'oai:myir:', # Prepended to the eprint id
  	  handler=>Logfile::EPrints::Repeated->new(
	    handler=>Logfile::EPrints::Institution->new(
	  	  handler=>$MyHandler,
	  )),
	),
  );
  open my $fh, "<access_log" or die $!;
  $parser->parse_fh($fh);
  close $fh;

  package MyHandler;

  sub new { ... }
  sub AUTOLOAD { ... }
  sub fulltext {
  	my ($self,$hit) = @_;
	printf("%s requested %s (%s)\n",
	  $hit->hostname||$hit->address,
	  $hit->page,
	  $hit->identifier,
	);
  }

=head1 SEE ALSO

L<Logfile::EPrints>

=head1 AUTHOR

=over 4

=item *

Timothy D Brody, E<lt>tdb01r@ecs.soton.ac.ukE<gt>

=item *

Matthew Kerwin, E<lt>matthew.kerwin@qut.edu.auE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Timothy D Brody

Copyright (C) 2018, Matthew Kerwin and Queensland University of Technology

This file is part of Logfile::EPrints-bis

Logfile::EPrints-bis is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Logfile::EPrints-bis is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Logfile::EPrints-bis. If not, see https://www.gnu.org/licenses/.

=cut
