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
	my $url = "http://$ip/api/bioproject/search?external_db=GEO\&start=$i\&rows=$rows";
        #print STDERR "$url\n";
        open(FILE, "curl -s \"$url\" |") or die "Cannot open API\n";
	while(<FILE>) {
		exit 0 unless(/\[\{\"EXPERIMENT\":/);
		s/\{\"EXPERIMENT\":/\n\{\"EXPERIMENT\":/g;
                print "$_";
        }
	close FILE;
	sleep $sleep;
}
