#!/usr/bin/perl
# STDIN: xRX.json
# STDOUT: xRX -> instrument_model (sequencer information)
# extract xRX and INSTRUMENT_MODEL from xRX.json

while(<STDIN>) {
	chomp;
	my $xrx = $1 if(/\"([DES]RX\d+)\"/); #xRX
	my $inst_model = $1 if(/\"INSTRUMENT_MODEL\":\s+\"([^\"]+)\"/); #{"INSTRUMENT_MODEL": "Illumina Genome Analyzer IIx"}
	print "$xrx\t$inst_model\n";
}
