#!/usr/bin/perl
# STDIN: xRX.json
# STDOUT: xRX -> instrument_model (sequencer information)
# extract xRX and INSTRUMENT_MODEL from xRX.json

#my $zcat = "pigz -cd"; 
my $zcat = "gzip -cd";

# SRA_Accessions.tab from NCBI retrieved by
# lftp -c 'open ftp.ncbi.nlm.nih.gov/sra/reports/Metadata && pget -n 8 SRA_Accessions.tab'
# then gzipped
my $file = "xRX.json.gz";

while(<STDIN>) {
	chomp;	
	my($xrx, $prj)=split(/\t/);
	$prjof{$xrx} = $prj;
}

open(FILE, "$zcat $file |") or die;
while(<FILE>) {
	chomp;
	my $xrx = $1 if(/\"([DES]RX\d+)\"/); #xRX
	my $inst_model = $1 if(/\"INSTRUMENT_MODEL\":\s+\{\"\$\":\s+\"([^\"]+)\"/);
	#my $lib_strate = $1 if(/\"LIBRARY_STRATEGY\":\s+\{\"\$\":\s+\"([^\"]+)\"/);
	#my $bioproject = $1 if(/\"(PRJ[DEN][A-Z]\d+)\"/);  #"PRJEB40279", "@namespace": "BioProject"
	print "$xrx\t$prjof{$xrx}\t$inst_model\n";
	#print "$xrx\t$bioproject\t$inst_model\n";
}
close FILE;
