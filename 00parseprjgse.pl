
while(<STDIN>) {
	chomp;
	print "$1\t" if(/\"(PRJ[A-Z][A-Z]\d+)\"/); #PRJ
	print "E-GEOD-$1" if(/\"ID\":\s+\"GSE(\d+)\"/); #GEO
	print "\n";
}
