#!/usr/bin/perl
# script to extract description about entries from retrieved xRX json
# for AOE (incomplete, yet)

# STDIN: xRX.json (line break fix needed)
while(<STDIN>) {
	chomp;
	#next if(/(GSE\d+)/);
	#next if(/\"\@broker_name\":\s+\"ArrayExpress\"/);
	my $desc = $1 if(/\"Description\":\s+\"([^\"]+)\"/);
	my $pmid = $1 if(/\"PMID\":\s+\"([^\"]+)\"/);
	my $id   = $1 if(/\"ID\":\s+\"([^\"]+)\"/);
	my $xrx  = $1 if(/\"\@accession\":\s+\"([^\"]+)\"/);
	my $title = $1 if(/\"Title\":\s+\{\"\$\":\s+\"([^\"]+)\"/i);
	my $organismname = $1 if(/\"OrganismName\":\s+\"([^\"]+)\"/);
	my $submitted = $1 if(/\"\@submitted\":\s+\"([^\"]+)\"/);
	my $method_type = $1 if(/\"\@method_type\":\s+\"([^\"]+)\"/);
	my $datatype = $1 if(/\"\DataType\":\s+\"([^\"]+)\"/);
	my $bioproject = $1 if(/\"BioProject\",\s+\"\$\":\s+\"([^\"]+)\"/);  #"BioProject", "$": "PRJNA285604
	my $instrument = $1 if(/\"INSTRUMENT_MODEL\":\s+\{\"\$\":\s+\"([^\"]+)\"/);
	print "$xrx\t$bioproject\t$title\t$organismname\t$method_type\t$datatype\t$instrument\t$submitted\n";
	#next if($gse eq '');
	#print "$gse\t$instrument\n";
}
