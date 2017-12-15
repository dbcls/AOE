#!/usr/bin/perl
# script to retrieve D/E/SRX metadata

my $rows = 1000;
my $apip = "IP.txt";

open(FILE, "$apip") or die "Cannot open $apip\n";
while(<FILE>) {
	chomp;
	$ip = $_;
}
close FILE;

# counting the number of rows
open(FILE, "curl \"http://$ip/api/sra/experiment?library_strategy=RNA-Seq\" |") or die;
while(<FILE>) {
	chomp;
	$num = $1 if(/(\d+) items/);
}
close FILE;

# calculating interation number
my $num2 = int ($num/1000);
print "Iteration: $num2\n";

foreach my $i (0..$num2) { # modify the number 
	$start = $i*$rows;
	print STDERR "$i..";
	system("curl \"http://$ip/api/sra/experiment?library_strategy=RNA-Seq&start=$start&rows=$rows&data_type=full\" >> xRX.json");
	sleep 1;
}
# after the scraping, '\n' should be inserted by running following command
# perl -i~ -pe 's/\{\"EXPERIMENT\"/\n\{\"EXPERIMENT\"/g' xRX.json
