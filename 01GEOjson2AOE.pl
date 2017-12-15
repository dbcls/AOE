#!/usr/bin/perl
# script to extract description about entries from retrieved GEO json
# for AOE (incomplete, yet)

# STDIN: prj2gse.json (line break fix needed)
while(<STDIN>) {
	chomp;
	my $desc = $1 if(/\"Description\":\s+\"([^\"]+)\"/);
	my $pmid = $1 if(/\"PMID\":\s+\"([^\"]+)\"/);
	my $id   = $1 if(/\"ID\":\s+\"([^\"]+)\"/);
	my $title = $1 if(/\"Title\":\s+\"([^\"]+)\"/);
	my $organismname = $1 if(/\"OrganismName\":\s+\"([^\"]+)\"/);
	my $submitted = $1 if(/\"\@submitted\":\s+\"([^\"]+)\"/);
	my $method_type = $1 if(/\"\@method_type\":\s+\"([^\"]+)\"/);
	my $datatype = $1 if(/\"\DataType\":\s+\"([^\"]+)\"/);
	print "$id\t$organismname\t$title\t$method_type\t$datatype\t$submitted\n";
}
