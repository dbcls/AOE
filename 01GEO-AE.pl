#! /usr/bin/env perl

my ($aetab) = shift(@ARGV);
my $zcat = "/usr/bin/gzcat";

open(FILE, "$zcat $aetab |") or die "Cannot open $aetab \n";
while(<FILE>) {
	chomp;
	my($prj,$aeid) = split(/\t/); 
	if($aeid =~ /E\-GEOD\-(\d+)/)  {
		$gse = 'GSE'.$1;	#print "$gse\n";
		$gseinae{$gse} = $gse;
	} else { next; }
}
close FILE;

while(<STDIN>) {
	chomp;
	my($prj,$gse) = split(/\t/); 
	unless(defined($gseinae{$gse})) {
		print "$_\n";
	}
}

	
