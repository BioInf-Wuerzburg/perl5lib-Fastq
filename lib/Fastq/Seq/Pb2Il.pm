package Fastq::Seq::Pb2Il;

use lib '../';
use Data::Dumper;

sub Fastq::Seq::pb2il{
	my $self = shift->new;
	my %options = (
		'length'=>2,
		'insert'=>3,
		'paired'=>0,
		'step'=>1,
		@_
	);
	$options{'insert'} = $options{'length'} unless($options{'paired'});
	my $seq = $self->seq();
	# Create ranges
	my @ranges = ();
	for(my $start=0; $start<=(length($seq)-$options{'insert'}); $start+=$options{'step'}){
		push(@ranges, [$start, $options{'length'}]);
	}
	my $leftpairs = [$self->substr_seq(@ranges)];
	my $rightpairs = undef;
	if($options{'paired'}){
		@ranges = ();
		$self->reverse_complement();
		for(my $start=0; $start<=(length($seq)-$options{'insert'}); $start+=$options{'step'}){
			push(@ranges, [length($seq)-$start-$options{'insert'}, $options{'length'}]);
		}
		$rightpairs = [$self->substr_seq(@ranges)];
	}
	return ($leftpairs, $rightpairs);
}

1;
