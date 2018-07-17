#! /usr/bin/env perl
# script to fetch GEO metadata vi eutils
# example: curl  "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gds&id=200115948"

my $urlbase = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gds&id=";
my $i = 0;
my @ids;
my $curl = "curl -s";

while(<STDIN>) {
	chomp;
	$i++;
	push(@ids, $_);
	if($i % 100 == 0) {
		my $id = join(',', @ids);
		open (FILE, "$curl \"${urlbase}$id\" |") or die "$curl ${urlbase}$id failed.";
		while(<FILE>) {
			chomp;
			print "$_\n";
		}
		close FILE;
		print STDERR "$i..";
		sleep 1;
		# print "$id\n";
		@ids = ();
	}
}
	
