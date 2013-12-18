#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Fastq::Seq;
use Fastq::Parser;
use Fastq::Seq::Pb2Il;

my %options;

=head1 NAME 

Pb2Il.pl

=head1 DESCRIPTION

This script creates (paired) read files from a file with larger sequences (eg Illumina reads from PacBio reads).

=head1 USAGE

  $ perl Pb2Il.pl --in=<file> --out <filebase> [options]

=head1 OPTIONS

=over 25

=item --in=<file>

path to the fastq file containing the large reads.

=cut

$options{'in=s'} = \( my $opt_in );

=item --out=<FILEBASE>

path to the desired output files _1.fq and _2.fq is automatically appended to FILEBASE

=cut

$options{'out=s'} = \( my $opt_out );

=item --[no]paired

Specify if the output reads should be paired or not
(default: paired)

=cut

$options{'paired!'} = \( my $opt_paired = 1 );

=item --insert=<INT>

Insert size in bp
(default: 150)

=cut

$options{'insert=i'} = \( my $opt_insert = 150 );

=item --length=<INT>

Output read length 
(default: 100)

=cut

$options{'length=i'} = \( my $opt_length = 100 );

=item --step=<INT>

Step size in bp
(default: 150)

=cut

$options{'step=i'} = \( my $opt_step = 150 );

=item --[no]masked

Specify if lowercase letters should be considered as masked and therefore excluded from the output
(default: nomasked)

=cut

$options{'masked!'} = \( my $opt_masked = 0 );

=item --[no]opp-out

Specify if read pairs should be oriented oudwards (usual for jumping libraries, default is inward)
(default: noopp-out)

=cut

$options{'opp-out!'} = \( my $opt_oppout = 0 );

=item [--help] 

show help

=cut

$options{'help|?'} = \( my $opt_help );

=item [--man] 

show man page

=cut

$options{'man'} = \( my $opt_man );

=back




=head1 CODE

=cut

GetOptions(%options) or pod2usage(1);

pod2usage(1) if ($opt_help);
pod2usage(
	-verbose  => 99,
	-sections => "NAME|DESCRIPTION|USAGE|OPTIONS|LIMITATIONS|AUTHORS"
) if ($opt_man);

pod2usage( -msg => "Missing option --in or --out", -verbose => 0 )
  unless ( $opt_in && $opt_out );

open( OUT1, ">", $opt_out . "_1.fq" )
  or die "Can't open file $opt_out" . "_1.fq $!";
open( OUT2, ">", $opt_out . "_2.fq" )
  or die "Can't open file $opt_out" . "_2.fq $!"
  if ($opt_paired);
my $parser = Fastq::Parser->new('file' => $opt_in);
while ( my $seq = $parser->next_seq() ) {
	my @fragments = $seq->pb2il(
		'paired' => $opt_paired,
		'masked' => $opt_masked,
		'step'   => $opt_step,
		'insert' => $opt_insert,
		'length' => $opt_length,
		'opp-out' => $opt_oppout
	);
	foreach my $subseq ( @{ $fragments[0] } ) {
		print OUT1 $subseq;
	}
	if ($opt_paired) {
		foreach my $subseq ( @{ $fragments[1] } ) {
			print OUT2 $subseq;
		}
	}
}
close OUT1 or die "$!";
close OUT2 or die "$!" if ($opt_paired);

=head1 LIMITATIONS

This parser uses a static naming scheme, DIOMUGxxx and DIOMUTxxx intended for D. muscipula.

=head1 AUTHORS

=over

=item * Markus Ankenbrand, markus.ankenbrand@stud-mail.uni-wuerzburg.de

=back


