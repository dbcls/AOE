#!/usr/bin/perl
# script to extract description about entries from retrieved GEO json for AOE 

my $zcat = "/usr/bin/gzcat";
$xRX2instrument_f = "xRX2instrument_model.txt.gz";

# instrument: xRX2instrument_model.txt.gz
open(FILE, "$zcat $xRX2instrument_f |") or die "Cannot open $xRX2instrument_f \n";
while(<FILE>) {
# SRX1070623      PRJNA285604     Illumina HiSeq 2000
	chomp;
	my($xrx,$prj,$inst_model) = split(/\t/);
	$inst_modelof{$prj} = $inst_model;
}
close FILE;

# STDIN: prj2gse.json (line break fix needed)
while(<STDIN>) {
	chomp;
	my $desc = $1 if(/\"Description\":\s+\"([^\"]+)\"/);
	my $pmid = $1 if(/\"PMID\":\s+\"([^\"]+)\"/);
	my $id   = $1 if(/\"ID\":\s+\{\"\$\":\s+\"([^\"]+)\"/); 
	my $title = $1 if(/\"Title\":\s+\{\"\$\":\s+\"([^\"]+)\"/);
	my $organismname = $1 if(/\"OrganismName\":\s+\{\"\$\":\s+\"([^\"]+)\"/);
	my $accession = $1 if(/\"\@accession\":\s+\"([^\"]+)\"/);
	my $submitted = $1 if(/\"\@submitted\":\s+\"([^\"]+)\"/);
	my $method_type = $1 if(/\"\@method_type\":\s+\"([^\"]+)\"/); #eArray, eSequencing,
	#my $datatype = $1 if(/\"\DataType\":\s+\{\"\$\":\s+\"([^\"]+)\"/);

	next if($accession eq '');
#Proj    AE      Description     Date    ArrayType       ArrayGroup      Technology      Instrument      NGSGroup        Organisms       Rep_organism
	print "$accession\t$id\t$title\t$submitted\t";
	if($method_type eq 'eArray') {
		print "NA\tNA\tarray assay\tNA\tNA\t";
	} elsif ($method_type eq 'eSequencing') {
		if(defined($inst_modelof{$accession})) { 
			$inst_model = $inst_modelof{$accession};
			if(($inst_model =~ /hiseq/i) || ($inst_model =~ /nextseq/i)) {
				$ngsgroup = "Illumina";
			} else {
				$ngsgroup = "Others_NGS";
			}
		} else {
			$inst_model = 'NA';
			$ngsgroup = "Others_NGS";
		}
		print "NA\tNA\tsequencing assay\t$inst_model\t$ngsgroup\t";
	} else {
		print "NA\tNA\t$method_type\tNA\tNA\t";
	}		
	print "$organismname\t$organismname\n";
}
