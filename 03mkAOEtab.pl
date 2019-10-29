#!/usr/bin/env perl

my $zcat = "zcat";
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


while(<STDIN>) {
	chomp;
s/\\\"//g;	
	my $prjid = $1 if(/\"ProjectID\":.+(PRJ\w\w\d+)\"/);
	my $desc  = $1 if(/\"Description\": \{\"\$\":\s+\"([^\"]+)\"\}/); 
	my $org   = $1 if(/\"OrganismName\": \{\"\$\":\s+\"([^\"]+)\"\}/); 
        my $pmid = $1 if(/\"PMID\":\s+\"([^\"]+)\"/);
        my $submitted = $1 if(/\"\@submitted\":\s+\"([^\"]+)\"/);
        my $method_type = $1 if(/\"\@method_type\":\s+\"([^\"]+)\"/); #eArray, eSequencing,
#AE	Proj    GEO      Description     Date    ArrayType       ArrayGroup      Technology      Instrument      NGSGroup        Organisms       Rep_organism

	if(defined($inst_modelof{$prjid})) { 
		$inst_model = $inst_modelof{$prjid};
                if(($inst_model =~ /hiseq/i) || ($inst_model =~ /nextseq/i) || ($inst_model =~/illumina/i)) {
                        $ngsgroup = "Illumina";
                } else {
                        $ngsgroup = "Others_NGS";
                }
	} else {
                $inst_model = 'NA';
                $ngsgroup = "Unknown_NGS";
        }
	next if($org eq '');
	print "$prjid\tNA\tNA\t$desc\t$submitted\t";
	print "NA\tNA\tsequencing assay\t$inst_model\t$ngsgroup\t";
        print "$org\t$org\n";
}
