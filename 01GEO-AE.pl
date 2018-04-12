#! /usr/bin/env perl

my ($aetab) = shift(@ARGV);
my $zcat = "/usr/bin/gzcat";

open(FILE, "$zcat $aetab |") or die "Cannot open $aetab \n";
while(<FILE>) {
	chomp;
	my $gse = '';
	my($prj,$aeid) = split(/\t/); 
	if($aeid =~ /E\-GEOD\-(\d+)/)  {
		$gse = 'GSE'.$1;	#print "$gse\n";
		$gseinae{$gse} = $gse;
	} else { next; }
	if(s/^$prj\t$aeid\t/$prj\t$aeid\t$gse\t/) { # add GSE column
		print "$_\n";
	} else {
		print "$_\n";
		exit 1;
	}
}
close FILE;

while(<STDIN>) { # GEOtab
	chomp;
	my($prj,$gse) = split(/\t/); 
	unless(defined($gseinae{$gse})) {
		if(s/^$prj\t$gse\t/$prj\tNA\t$gse\t/) { # add NA(AEID)  column
			print "$_\n";
		} else {
			print "$_\n";
			exit 1;
		}
	}
}

	
