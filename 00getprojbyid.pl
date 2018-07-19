#! /usr/bin/env perl
# script to get BioProject by ID
# STDIN:  list of IDs
# STDOUT: API output
# usage: perl 00getprojbyid.pl < id_list_unique.txt | pigz -c > out.json.gz

my $rows = 100;
my $sleep = 1;
my $i = 0;
my $apip = "IP.txt";
my @ids;

# get IP of DBCLS SRA API
open(FILE, "$apip") or die "Cannot open $apip";
while(<FILE>) {
        chomp;
        $apip = $_;
}
close FILE;

# read list of IDs (BioProject)
while(<STDIN>) {
        chomp;
	$i++;
        push(@ids, "\"$_\"");
	if(($i % $rows) == 0) {
		my $id = join(',',@ids);
		#print 	"$id\n\n";
		@ids = ();
		&gethoge($id);
	}
}
$id = join(',',@ids);
&gethoge($id);


sub gethoge {
	open(FILE, "curl -s -X POST -d '{\"ids\":[$_[0]]}' http://$apip/api/bioproject |") or die "Cannot open API\n";
	# after the scraping, '\n' should be inserted by running the following command
        while(<FILE>) {
		s/\{\"Package/\n\{\"Package/g;
                print "$_\n";
        }
        close FILE;
	sleep $sleep;
}

