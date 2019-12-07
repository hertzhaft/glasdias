#! perl
use Mojo::Base 'strict';
use Mojo::File 'path';
use Mojo::Collection 'c';
use JSON::XS;
# use Text::Levenshtein::XS qw(distance);
# use Text::JaroWinkler qw( strcmp95 );
use Tie::IxHash;

no warnings 'uninitialized';

use Data::Printer {
  output => 'stdout',
	quote_keys => 1,
	filters => { SCALAR => [ sub { return "q{${$_[0]}}" },  ], },
	hash_separator => ' => ',
	align_hash => 0,
};

my $FILMS = {};
my $DIAS = [];
tie %$FILMS, 'Tie::IxHash';

my $LAST;
my $LASTDATE; # save date when the date field was used otherwise

my ($film, $year, $lfd, $slide, $slidenr, $filename, $item, $filmnr, $count);
my $cols = [qw(place building detail date)];

# raw data
my $file = path("diakatalog.txt")->slurp;
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
    $filmnr  = "$year-$lfd";
    $film = $FILMS->{$filmnr} = {};
    tie %$film, 'Tie::IxHash';
    @$film{qw(year film)} = ($year, $lfd);
    $slide = undef;
    reset_last;
    say STDERR $filmnr;
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
    $filename = sprintf("%d%s%02d", $year, $lfd, $slidenr);
    $slide = $film->{$slidenr} = {};
    tie %$slide, 'Tie::IxHash';
    @$slide{qw(name nr)} = ($filename, $slidenr);
    # say STDERR " $slidenr";
    $count = 0;
    return
    }

  # slide field
  if ($slide) {
    $item = ($_ eq '' || /^dto|_|\-/i) ? $LAST->[$count] : $_;
    $slide->{$cols->[$count]} = $item unless $count == 3; # date may be wrong
    if ($count == 0) {
      $item = '' unless $_;
      reset_place if (!$item || $item ne $LAST->[0]); # new place
      }
    $LAST->[$count] = $item unless $count == 2; # no saving for detail
    # date field
    if ($count == 3) {
      my $content = $_;
      my ($d, $m, $y) = $content =~ /(\d+)\.(\d+)\.(\d{4})?/;
      if (!$d) {
        if ($content gt ' ') { # no date, but other content
          $content = ", $content" if ($slide->{detail} gt '');
          $slide->{detail} .= $content;
          }
        $slide->{datecalc} = $LASTDATE; # copy last datecalc
        }
      else { # new date
        $slide->{datecalc} = $LASTDATE = $d
          ? sprintf("%04d-%02d-%02d", $y || $year, $m, $d)
          : $year;
        }
      }
    $count++;
    return
    }

  # additional content
  $film->{addinfo} .= "$_/" if $_;
  });

my $coder = JSON::XS->new->pretty;
path('diakatalog.json')->spurt($coder->encode($FILMS));

my $handle = path('diakatalog.tab')->open('w');
$handle->say(join("\t", qw(name place building detail date datecalc camera product year film nr)));
for my $film (values %$FILMS) {
  for my $nr (1 .. 40) {
  	my $dia = $film->{$nr};
    next unless $dia;
    $handle->say(join("\t", @$dia{qw(name place building detail date datecalc)}, @$film{qw(camera product year film)}, $nr));
    my $slide = {};
    $slide->{$_} = $film->{$_} for qw(camera product year film);
    $slide->{$_} = $dia->{$_} for qw(name place building detail date datecalc);
    push @$DIAS, $slide;
  }
}
$handle->close;

path('diakatalog.pm')->spurt(np($DIAS));