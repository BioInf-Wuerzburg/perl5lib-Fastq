package Fastq::Seq::Pb2Il;

use lib '../';
use Data::Dumper;
use strict;
use warnings;

sub Fastq::Seq::pb2il {
	my $self    = shift->new;
	my %options = (
		'length' => 2,
		'insert' => 3,
		'paired' => 0,
		'step'   => 1,
		'masked' => 0,
		@_
	);
	$options{'insert'} = $options{'length'} unless ( $options{'paired'} );
	my $comp;
	if ( $options{'paired'} ) {
		$comp = $self->new;
		$comp->reverse_complement();
	}
	my $seq = $self->seq();
	
	my %illegal_startpoints = ();
	if ( $options{'masked'} ) {
		while($seq =~ /([a-z])/g ){
			my $position = pos($seq);
			for(my $i=($position-$options{'insert'}); $i<($position-$options{'insert'}+$options{'length'}); $i++){
				$illegal_startpoints{$i} = 1;
			}
			for(my $i=$position-$options{'length'}; $i<$position; $i++){
				$illegal_startpoints{$i} = 1;
			}
		}
	}
	# Create ranges
	my @ranges    = ();
	my @ranges_rc = ();
	for (my $start = 0 ; $start <= ( length($seq) - $options{'insert'} ) ; $start += $options{'step'}){
		next if($illegal_startpoints{$start});
		push( @ranges, [ $start, $options{'length'} ] );
		if ( $options{'paired'} ) {
			push(@ranges_rc,[length($seq) - $start - $options{'insert'},$options{'length'}]);
		}
	}
	my $leftpairs  = [ $self->substr_seq(@ranges) ];
	my $rightpairs = undef;
	if($options{'paired'}){
		$rightpairs = [ $comp->substr_seq(@ranges_rc) ];
	}
	return $options{'paired'} ? ( $leftpairs, $rightpairs ) : ( $leftpairs );
}

1;
