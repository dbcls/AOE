#! /usr/bin/env perl
# script to get GSE and related data from BioProject

my $rows = 1000;
my $sleep = 1;
my $apip = "IP.txt";

# get IP of DBCLS SRA API
open(FILE, "$apip") or die "Cannot open $apip";
while(<FILE>) {
        chomp;
        $ip = $_;
}
close FILE;

open(FILE, "curl -s \"http://$ip/api/bioproject?external_db=GEO&rows=0\" |") or die "Cannot open API\n"; 
while(<FILE>) {
	chomp;
	#$prjgsenum = $1 if(/(\d+) items/);
	$prjgsenum = $1 if(/\"numFound\": (\d+)/);
}
close FILE;

# calculating interation number
my $prjgsenum2 = int ($prjgsenum/1000);
print STDERR "Iteration: $prjgsenum2 times\n";

# iteration
foreach my $i (0..$prjgsenum2) {
	$start = $i*$rows;
	print STDERR "$i..";
	open(FILE, "curl -s \"http://$ip/api/bioproject?external_db=GEO&start=$start&rows=$rows&data_type=full\" |") or die "Cannot open API\n";
	# after the scraping, '\n' should be inserted by running the following command
        while(<FILE>) {
		s/\{\"Package/\n\{\"Package/g;
                print "$_\n";
        }
        close FILE;
	sleep $sleep;
}
