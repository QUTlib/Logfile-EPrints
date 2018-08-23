# Logfile::EPrints-bis

A fork of [Logfile::EPrints](https://metacpan.org/pod/Logfile%3A%3AEPrints),
originally by [Tim Brody](https://metacpan.org/author/TIMBRODY).

### Name

`Logfile::EPrints` - Process Web log files for institutional repositories

### Synopsis

```perl
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
      printf("%s from %s requested %s (%s)\n",
        $hit->hostname||$hit->address,
        $hit->institution||'Unknown',
        $hit->page,
        $hit->identifier,
      );
}
```

### Description

The `Logfile::*` modules provide a means to analyze log files from Web servers (typically
Institutional Repositories) by translating HTTP requests into more informative data e.g. a full-text
download by a user at Caltech.

The architectural design consists of a series of pluggable filters that read from a log file or
stream into Perl objects/callbacks. The first filter in the stream needs to convert from the log
file format into a record object representing a single "hit". Subsequent filters can then ignore
hits (e.g. from robots) and/or augment them with additional data (e.g. country of origin by GeoIP2).

A record object (based on `Logfile::EPrints::Hit`) stores data about a request and may provide
derived information on demand (e.g. translate a hostname to IP address).

Filters in Logfile::EPrints fall into three catagories: parsers, mappers and filters.

#### Parsers

A parser retrieves data from a raw web log source and for every log entry it creates a record object
and passes this onto it's handler as a 'hit' event. Between the parser and the record object any
translation required by the used mappers/filters needs to happen.

#### Mappers

Mappers are responsible for mapping HTTP requests into logical requests in the repository. An HTTP
request might be a "200" response to the page `/200/3` that corresponds to a logical request for
document `3` in the eprint record `200`. A mapper would typically translate the generic 'hit'
invent into other events by calling a different method on its downstream handler.

#### Filters

A filter does the legwork in processing log files. A filter may ignore records (e.g. records
resulting from robot activity) or add data to the record.

As a special (alpha) case a filter may return a record derived from `Logfile::EPrints::Hit::Negate`
that means 'remove records matching this query'. Therefore filters must return whatever is returned
by the downstream handler.

To be useful the final filter will need to write the resulting data to file or, more likely, a
database.

### Handler Callbacks

`Logfile::EPrints` is weakly typed and doesn't (currently) proscribe what data a record may contain
nor the type of events that can happen in a repository. However, the built-in mappers at most use
the following four events:

#### abstract()

A request for an abstract 'jump-off' page (vs. a fulltext request).

#### fulltext()

A request for a full-text object e.g. HTML document, PDF, image etc.

#### browse()

A request for a browsable list e.g. a subject-based listing.

#### search()

An internal repository search.

### Author

* Timothy D Brody, <tdb01r@ecs.soton.ac.uk>
* Matthew Kerwin, <matthew.kerwin@qut.edu.au>

### Copyright and License

The original Logfile::EPrints library is Copyright (C) 2005 by Timothy D Brody.  It is free
software; you can redistribute it and/or modify it under the same terms as Perl itself, either Perl
version 5.8.6 or, at your option, any later version of Perl 5 you may have available.

Logfile::EPrints-bis is derived from Logfile::EPrints, and is copyright (C) 2018, Matthew Kerwin
and Queensland University of Technology.

Logfile::EPrints-bis is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Logfile::EPrints-bis is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Logfile::EPrints-bis.  If not, see <https://www.gnu.org/licenses/>.

