#! perl
use Mojo::Base 'strict';
use Mojo::File 'path';
use Mojo::Collection 'c';
use Hash::Ordered;
use JSON::XS;
use Text::Levenshtein::XS qw(distance);
use Text::JaroWinkler qw( strcmp95 );
use Tie::IxHash;

no warnings 'uninitialized';

use Data::Printer {
  output => 'stdout',
	quote_keys => 1,
	# filters => { SCALAR => [ sub { return "q{${$_[0]}}" },  ], },
	hash_separator => ' => ',
	align_hash => 0,
};

my $FILMS = {};
tie %$FILMS, 'Tie::IxHash';

my $LAST;

my ($film, $year, $lfd, $slide, $slidenr, $filename, $item, $name, $count);
my $cols = [qw(place building detail date)];

# raw data
my $file = path("dias-schelbert.txt")->slurp;
my $lines = c(split /\n/, $file);

sub max { $_[$_[0] < $_[1]] }
sub maxlen { max(length($_[0]), length($_[1])) }

sub reset_last  { $LAST = ['','','',''] }
sub reset_place { @$LAST[0..2] = ('','','') }

$lines->each(sub {
  # new film
  if (/^[09]\d\d\da?$/) {
    $year = /^0/ ? 2000 : 1900;
    $year += substr($_,0,2);
    $lfd = substr($_,2,3);
    $name  = "$year-$lfd";
    $film = $FILMS->{$name} = {};
    tie %$film, 'Tie::IxHash';
    @$film{qw(year film)} = ($year, $lfd);
    $slide = undef;
    reset_last;
    say STDERR $name;
    return
    }

  # film data
  if (/^~/) {
    @$film{qw(product camera developer)} = $_ =~/^~F: ?([^#]*)#K: ?([^#]*)#E: ?([^#]*)/;
    return
    }

  # slide number
  if (/^\d+$/) {
    $slidenr = substr($_,-2,2);
    $filename = sprintf("gsch-%d-%s-%02d", $year, $lfd, $slidenr);
    $slide = $film->{$slidenr} = {};
    tie %$slide, 'Tie::IxHash';
    @$slide{qw(filename nr)} = ($filename, $slidenr);
    # say STDERR " $slidenr";
    $count = 0;
    return
    }

  # slide field
  if ($slide) {
    $item = ($_ eq '' || /^dto|_|\-/) ? $LAST->[$count] : $_;
    $slide->{$cols->[$count]} = $item;
    reset_place if ($count == 0 && $item ne $LAST->[0]); # new place
    $LAST->[$count] = $item unless $count == 2; # no saving for detail?
    # calculate date
    if ($count == 3) {
      my $date = $_ || $LAST->[3];
      my ($d, $m, $y) = $date =~ /(\d+)\.(\d+)\.(\d{4})?/;
      $y ||= $year;
      $slide->{calc} = $d ? sprintf("%04d-%02d-%02d", $y,$m,$d) : $y;
      }
    $count++;
    return
    }

  # additional content
  $film->{addinfo} .= "$_/" if $_;
  });

my $coder = JSON::XS->new->pretty;
path('dias.json')->spurt($coder->encode($FILMS));

my $handle = path('dias.tab')->open('w');
$handle->say(join("\t", qw(filename place building detail date calc camera product year film nr)));
for my $f (values %$FILMS) {
  for my $s (1 .. 36) {
    next unless exists($f->{$s}); 
    my $d = $f->{$s};
    $handle->say(join("\t", @$d{qw(filename place building detail date calc)}, @$f{qw(camera product year film)}, $s));
  }
}
$handle->close;