package Logfile::EPrints::Filter::Repeated;

require bytes;
use Fcntl;
use SDBM_File;

use constant CACHE_TIMEOUT => 60*60*24; # 1 day
use constant REPEATS_CACHE => '/usr/local/share/Logfile/repeatscache.db';
use vars qw( $AUTOLOAD );

sub new
{
	my ($class,%args) = @_;
	my $self = bless \%args, ref($class) || $class;
	my $filename = $args{'file'} || REPEATS_CACHE;
	tie %{$self->{cache}}, 'SDBM_File', $filename, O_CREAT|O_RDWR, 0644
		or die "Unable to open repeats cache database at $filename: $!";
	my @KEYS;
	while( my ($key, $value) = each %{$self->{cache}} )
	{
		push @KEYS, $key if( $value < time - CACHE_TIMEOUT );
	}
	delete $self->{cache}->{$_} for @KEYS;
	$self;
}

sub DESTROY
{
	untie %{$_[0]->{cache}};
}

sub AUTOLOAD
{
	return if $AUTOLOAD =~ /[A-Z]$/;
	$AUTOLOAD =~ s/^.*:://;
	shift->{handler}->$AUTOLOAD(@_);
}

sub fulltext
{
	my ($self,$hit) = @_;
	my $r;
	my $key = $hit->address . 'x' . $hit->identifier;
	if( defined($self->{cache}->{$key}) &&
		($hit->utime - $self->{cache}->{$key}) <= CACHE_TIMEOUT
	) {
		$r = $self->{handler}->repeated($hit);
	} else {
		$r = $self->{handler}->fulltext($hit);
	}
	$self->{cache}->{$key} = $hit->utime;
	return $r;
}

1;

=pod

=head1 NAME

Logfile::EPrints::Filter::Repeated - Catch fulltext events and check for repeated requests

=head1 DESCRIPTION

This filter catches fulltext events and either forwards the fulltext event or, if the same identifier has been requested by the same address within 24 hours, create a repeated event.

=head1 TODO

Free memory by removing requests older than 24 hours.

=head1 HANDLER CALLBACKS

=over 4

=item repeated()

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Timothy D Brody

Copyright (C) 2018, Matthew Kerwin and Queensland University of Technology

This file is part of Logfile::EPrints-bis

Logfile::EPrints-bis is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Logfile::EPrints-bis is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Logfile::EPrints-bis. If not, see https://www.gnu.org/licenses/.

=cut
