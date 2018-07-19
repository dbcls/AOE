#!/usr/bin/perl
# STDIN: xRX.json
# STDOUT: xRX -> instrument_model (sequencer information)
# extract xRX and INSTRUMENT_MODEL from xRX.json

my $zcat = "pigz -cd"; 

# SRA_Accessions.tab from NCBI retrieved by
# lftp -c 'open ftp.ncbi.nlm.nih.gov/sra/reports/Metadata && pget -n 8 SRA_Accessions.tab'
# then gzipped
my $file = "SRA_Accessions.tab.gz";
#my $file = "SRA_Accessions.tab";

open(FILE, "$zcat $file |") or die;
while(<FILE>) {
	chomp;	
	my $prj = $1 if(/(PRJ\w\w\d+)/);	#PRJNA
	if(/([DES]RX\d+)\t/) { #xRX
		my $xrx = $1;
		$prjof{$xrx} = $prj;
	}
}
close FILE;

while(<STDIN>) {
	chomp;
	my $xrx = $1 if(/\"([DES]RX\d+)\"/); #xRX
	my $inst_model = $1 if(/\"INSTRUMENT_MODEL\":\s+\{\"\$\":\s+\"([^\"]+)\"/);
	#my $bioproject = $1 if(/\"BioProject\",\s+\"\$\":\s+\"([^\"]+)\"/);  #"BioProject", "$": "PRJNA285604
	print "$xrx\t$prjof{$xrx}\t$inst_model\n";
}
