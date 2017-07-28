
use File::Basename 'basename', 'dirname';

my $arrayfile = "/home/bono/AOE/99A.txt";
my $xrx2inst_file = "/home/bono/AOE/xRX2instrument_model.txt.gz";

#lookup arrayname for human being
open(FILE, $arrayfile) or die;
while(<FILE>) {
	chomp;
	my($id,$text) = split(/\t/); 
	$nameofarray{$id} = $text;
}
close FILE;

#lookup instrument_model for xRX
open(FILE, "zcat -dc $xrx2inst_file |") or die "$!: $xrx2inst_file\n";
while(<FILE>) {
	chomp;
	my ($xrx, $instrument_model) = split(/\t/);
	$instrument_modelof{$xrx} = $instrument_model;
}
close FILE;

# print header line 
print "ID\tDescription\tDate\tArrayType\tArrayGroup\tTechnology\tInstrument\tNGSGroup\tOrganisms\tRep_organism\n"; # organism
while(<STDIN>) { #idf file list from STDIN
	chomp;
	my $idf = $_;
	my $id = '';
	if($idf =~ /(E\-\w+\-\d+)/) {
		$id = $1;
	} else { next; }
	my $exprdir = dirname $idf;
	my $description  = "";
	my $prdate = "";
	open(IDF, $idf) or die "$!:$idf\n";
	my $line = '';
	while(<IDF>) {
		s/\r/\n/g;
		$line .= $_;
	}
	close IDF;
	foreach my $value (split(/\n/,$line)) {
		my($zero) = split(/\t/,$value); #id
		$value =~ s/^$zero\t//; #propery
		$value =~ s/\t+//g; #remove a lot of \t
		if($zero eq 'Investigation Title') {
			$value =~ s/^\"//; $value =~ s/\"$//;
			$description = $value;
		}
		$prdate = $value if($zero eq 'Public Release Date');
	}
	print "$id\t$description\t$prdate\t";
	my $sdrf = "$exprdir/$id.sdrf.txt";
	$sdrf = "$exprdir/$id.hyb.sdrf.txt" unless(-f $sdrf);
	$sdrf = "$exprdir/$id.seq.sdrf.txt" unless(-f $sdrf);
	unless(-f $sdrf) { print "\n"; next; }
	my $i = 0;
	my $i1 = undef;
	my $i2 = undef;
	my $i3 = undef;
	my $i4 = undef;
	my $maxorgno = 0;
	my $rep_organism = '';
	my $maxarrayno = 0;
	my $rep_array = '';
	my $instrumentmodel = '';
	my $technologylist = '';
	undef %marrays;
	undef %organisms;
	undef @values;
	undef %technologies;
	undef %instrumentmodels;
	undef %ena_experiments;
	open(SDRF, $sdrf) or die "$!:$sdrf\n";
	while(<SDRF>) {
		chomp;
		my @values = split(/\t/);
		if($i == 0) {
			foreach my $value (@values) {
				$i1 = $i if($value =~ /Array\s+Design\s+REF/i);
				$i2 = $i if(($value =~ /Characteristics/i) && ($value =~ /\[Organism\]/i));
				$i3 = $i if($value =~ /Technology\s+Type/i);
				$i4 = $i if($value =~ /\[instrument_model\]/i);
				$i5 = $i if($value =~ /\[ENA_EXPERIMENT\]/i);
				$i++;
			}
			#last unless(defined($i1));
			#last unless(defined($i2));
		} else {
			$values[$i1] =~ s/^\s+// if(defined($values[$i1])); #trim heading spaces
			$values[$i2] =~ s/^\s+// if(defined($values[$i2])); #trim heading spaces
			#$values[$i3] =~ s/^\s+//; #trim heading spaces
			$values[$i1] =~ s/\"//g if(defined($values[$i1]));  #trim double quotes
			$values[$i2] =~ s/\"//g if(defined($values[$i2]));  #trim double quotes
			#$values[$i3] =~ s/\"//g;  #trim double quotes
			$marrays{$values[$i1]}++   if(($i1 > 0) && ($values[$i1] =~ /\w/)); #Array Design REF
			$organisms{$values[$i2]}++ if(($i2 > 0) && ($values[$i2] =~ /\w/)); #Organism
			$technologies{$values[$i3]}++ if(($i3 > 0) && ($values[$i3] =~ /\w/)); #Technology 
			$instrumentmodels{$values[$i4]}++ if(($i4 > 0) && ($values[$i4] =~ /\w/)); #instrument model
			$ena_experiments{$values[$i5]}++ if(($i5 > 0) && ($values[$i5] =~ /\w/)); #ENA_EXPERIMENT
		}
	}
	close SDRF;

	foreach my $marray (keys %marrays) {
		print "$nameofarray{$marray}($marray)\[$marrays{$marray}\] " if(defined($nameofarray{$marray}));
		if( $marrays{$marray} > $maxarrayno){ 
			$rep_array = $nameofarray{$marray};
			$maxarrayno = $marrays{$marray};
		}
	}
	print "\t";
	if($rep_array =~ /affymetrix/i) { #arraygroup
		print "Affymetrix\tarray assay\tNA\tNA";
	} elsif($rep_array =~ /agilent/i) {
		print "Agilent\tarray assay\tNA\tNA";
	} else {# Other includes mostly NGS
		print "Others\t";
		foreach my $technology (keys %technologies) {
			print "$technology ";
			$technologylist .= $technology;
		}
		print "\t";
		if($technologylist =~ /sequencing/i) { #NGS
			my $instlist = '';
			foreach $instrumentmodel (keys %instrumentmodels) {
				$instlist .= $instrumentmodel;
			}
# code for recent metadata
			unless($instlist =~ /\w/) {
			 	foreach my $xrx (keys %ena_experiments) {
					#lookup instrument_model for xRX.	
					$instlist = $instrument_modelof{$xrx}; # not deal with multiple sequencer in the same xRX
				}
			}	
			print "$instlist";
			if($instlist =~ /illumina/i) {
				$ngsgroup = "Illumina";
			} else {
				$ngsgroup = "Others";
			}
			print "\t$ngsgroup";
		} else { # no NGS
			print "\tNA";
		}
	}
	print "\t";
	foreach my $organism (keys %organisms) {
		print "$organism\[$organisms{$organism}\] ";
		if( $organisms{$organism} > $maxorgno){ 
			$rep_organism = $organism;
			$maxorgno = $organisms{$organism};
		}
	}
	print "\t";
	print "$rep_organism";
	print "\n";
}

exit 0;

