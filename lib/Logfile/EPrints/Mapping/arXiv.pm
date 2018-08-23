package Logfile::EPrints::Mapping::arXiv;

use strict;
use warnings;

use URI;

sub new {
	my ($class,%args) = @_;
	bless \%args, $class;
}

sub hit {
	my ($self,$hit) = @_;
	if( !defined($hit->code) or $hit->code =~ /\D/ )
	{
		Carp::carp("No or invalid response code for: ".$hit->{raw});
		return;
	}
	if( 'GET' eq $hit->method && 200 == $hit->code ) {
		my $path = URI->new($hit->page,'http')->path;
		$path =~ s/\/other//;
		if( $path =~ /^\/((PS_cache)|(ftp))/ ) {
			$path =~ s/\/\w+\/\d{4}\//\//;
		}
		if( $path =~ /^\/(abs|pdf|ps|PS_cache|dvi|ftp|e-print)\/([A-Za-z\-\.]+)\/?([0-9]{7})/ ) {
			my ($t,$i,$n) = ($1,$2,$3);
			$i=~ s/(?<=\w)\.\w+$//;
			$hit->{identifier} = 'oai:arXiv.org:'.$i.'/'.$n;
			if( $t eq 'abs' ) {
				$self->{handler}->abstract($hit);
			} else {
				$self->{handler}->fulltext($hit);
			}
		# arXiv:0704.0021, introduced Apr 2007
		} elsif( $path =~ /^\/(abs|pdf|ps|PS_cache|dvi|ftp|e-print)\/(?:arxiv\/)?([0-9]{4}\.[0-9]{4,})/ ) {
			my( $type, $identifier ) = ($1,$2);
			$hit->{identifier} = 'oai:arXiv.org:' . $identifier;
			if( $type eq 'abs' ) {
				$self->{handler}->abstract($hit);
			} else {
				$self->{handler}->fulltext($hit);
			}
		} elsif( $path =~ /^\/list/ ) {
			$self->{handler}->browse($hit);
		} elsif( $path =~ /^\/find/ ) {
			$self->{handler}->search($hit);
		# Index / Image requests / help
		# Other requests:
		# \/ = index
		# ^\/icon|uk\.gif = images
		# ^\/help = help pages
		# ^\/form = browsing form
		# ^\/css = stylesheets
		# ^\/format = list available full-text formats
		#} elsif( $path eq '/' || $path =~ /^\/(icon|help|form)|uk\.gif|robots.txt/) {
		} else {
#			warn "Unhandled request type: $path\n$hit->{raw}\n";
		}
	}
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Logfile::EPrints::Mapping::arXiv - Parse Apache logs from an arXiv mirror

=head1 SYNOPSIS

  use Logfile::EPrints;

  my $parser = Logfile::EPrints::Parser->new(
	handler=>Logfile::EPrints::Mapping::arXiv->new(
  	  handler=>Logfile::EPrints::Repeated->new(
	    handler=>Logfile::EPrints::Institution->new(
	  	  handler=>$my_handler,
	  )),
	),
  );
  open my $fh, "<", "access_log" or die $!;
  $parser->parse_fh($fh);
  close($fh);

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

=head1 DESCRIPTION

See L<Logfile::EPrints>.

=head1 HANDLER CALLBACKS

=over 4

=item abstract()

=item browse()

=item fulltext()

=item search()

=back

=head1 SEE ALSO

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
