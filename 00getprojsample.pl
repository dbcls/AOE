#!/usr/bin/perl
# script to get GSE and related data from BioProject

my $prj2gse = "prj2gse.json";
unlink $prj2gse;
my $rows = 1000;
my $apip = "IP.txt";

# get IP of DBCLS SRA API
open(FILE, "$apip") or die "Cannot open $apip";
while(<FILE>) {
        chomp;
        $ip = $_;
}
close FILE;

open(FILE, "curl \"http://$ip/bioproject?external_db=GEO\" |") or die;
while(<FILE>) {
	chomp;
	$prjgsenum = $1 if(/(\d+) items/);
}
close FILE;

# calculating interation number
my $prjgsenum2 = int ($prjgsenum/1000);
print "$prjgsenum2\n";

# iteration
foreach my $i (0..$prjgsenum2) {
	$start = $i*$rows;
	print STDERR "$i..";
	system("curl \"http://$ip/bioproject?external_db=GEO&start=$start&rows=$rows&data_type=full\"  >> $prj2gse");
	sleep 1;
}
# after the scraping, '\n' should be inserted by running the following command
# perl -i~ -pe 's/\{\"Package/\n\{\"Package/g' prj2gse.json
