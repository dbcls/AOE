#!/usr/bin/perl
# STDIN: xRX.json
# STDOUT: xRX -> instrument_model (sequencer information)
# extract xRX and INSTRUMENT_MODEL from xRX.json

#my $zcat = "pigz -cd"; 
my $zcat = "gzip -cd";

# SRA_Accessions.tab from NCBI retrieved by
# lftp -c 'open ftp.ncbi.nlm.nih.gov/sra/reports/Metadata && pget -n 8 SRA_Accessions.tab'
# then gzipped
my $file = "SRA_Accessions.tab.gz";

open(FILE, "$zcat $file |") or die;
while(<FILE>) {
	chomp;	
	my $prj = $1 if(/(PRJ\w\w\d+)/);	#PRJNA
	if(/([DES]RX\d+)\t/) { #xRX
		my $xrx = $1;
		print "$xrx\t$prj\n";
	}
}
close FILE;
