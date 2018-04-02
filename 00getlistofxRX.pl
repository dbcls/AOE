#!/usr/bin/perl
# script to retrieve D/E/SRX metadata

my $rows = 1000;
my $sleep = 3;
my $apip = "IP.txt";

open(FILE, "$apip") or die "Cannot open $apip\n";
while(<FILE>) {
	chomp;
	$ip = $_;
}
close FILE;

# counting the number of rows
open(FILE, "curl -s \"http://$ip/api/sra/experiment?library_strategy=RNA-Seq&rows=0\" |") or die;
while(<FILE>) {
	chomp;
	#$num = $1 if(/(\d+) items/);
	$num = $1 if(/\"numFound\": (\d+)/);
}
close FILE;

# calculating interation number
my $num2 = int ($num/1000);
print STDERR "Iteration: $num2\n";

foreach my $i (0..$num2) { # modify the number 
	$start = $i*$rows;
	print STDERR "$i..";
	open(FILE, "curl -s \"http://$ip/api/sra/experiment?library_strategy=RNA-Seq&start=$start&rows=$rows&data_type=full\" |") or die;
        while(<FILE>) {
		s/\{\"EXPERIMENT\"/\n\{\"EXPERIMENT\"/g;
		print "$_\n";
	}
	close FILE;
	sleep $sleep;
}
