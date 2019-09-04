#!/usr/bin/perl
# script to retrieve D/E/SRX metadata
# JSON version
# Hidemasa Bono
 
my $rows = 10000;
my $num2 = 9999999;
my $sleep = 1;
my $apip = "IP.txt";

open(FILE, "$apip") or die "Cannot open $apip\n";
while(<FILE>) {
	chomp;
	$ip = $_;
}
close FILE;

# example: http://xx.xx.xx.xx/api/sra/search?library_strategy=RNA-seq&start=1&rows=1
foreach my $i (1..$num2) { # modify the number 
	print STDERR "$i..";
	open(FILE, "curl -s \"http://$ip/api/sra/search?library_strategy=RNA-seq&start=$i&rows=$rows\" |") or die "$!:$file\n";
	while(<FILE>) {
		exit 0 unless(/\[\{\"EXPERIMENT\":/);
		s/\{\"EXPERIMENT\":/\n\{\"EXPERIMENT\":/g;
                print "$_";
        }
	close FILE;
	sleep $sleep;
}
