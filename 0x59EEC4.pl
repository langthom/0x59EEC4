#!/usr/bin/perl -w
use strict;
use PerlSpeak;

my @NAMES = (
    [qw(oh one two three four five six seven eight nine ann bet christ dot ernest frost)],
    [qw(ten eleven twelve thirteen forteen fifteen sixteen seventeen eighteen nineteen annteen betteen christeen dotteen ernesteen frosteen)],
    [qw(- - twenty thirty forty fifty sixty seventy eighty ninety annty betty christy dotty ernesty frosty)]
);

sub translateByte {
    my ($byte) = @_;
    my ($nibble1, $nibble2) = (($byte >> 4) & 0xf, $byte & 0xf);
    return "$NAMES[0][$nibble2]" if $nibble1 == 0;
    return "$NAMES[1][$nibble2]" if $nibble1 == 1;
    return "$NAMES[2][$nibble1]" if $nibble2 == 0;
    return qq{$NAMES[2][$nibble1]-$NAMES[0][$nibble2]};
}


my $speeker = PerlSpeak->new();
$speeker->{tts_engine} = "festival";
$speeker->{echo_off} = 1;
$speeker->{volume} = 5;

my ($filename) = @ARGV;

if(not defined $filename) {
  # no file, say the following test bytes
  my @values = (0xf2, 0x2f, 0x5b, 0x3e, 0xa0, 0x07, 0xde, 0xaf, 0x29, 0x2a, 0xac);
  $speeker->say(translateByte($_)) foreach (@values);
  exit;
}

# file provided, read it in chunks of 1024 bytes and say them.
open my $file, '+<:raw', $filename or die $!;

while(1) {
  my $read_success = read $file, my $buf, 1024;
  die $! if not defined $read_success;
  last if not $read_success;
  $speeker->say(translateByte(ord($_))) foreach (split //, $buf);
}

close $file;