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

open(FILE, "curl -s \"http://$ip/api/bioproject?external_db=GEO\" |") or die;
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
        open(FILE, "curl -s \"http://$ip/api/sra/experiment?library_strategy=RNA-Seq&start=$start&rows=$rows&data_type=full\" |") or die;
        open(FILE, "curl -s \"http://$ip/api/bioproject?external_db=GEO&start=$start&rows=$rows&data_type=full\" |") or die;
        # after the scraping, '\n' should be inserted by running the following command
        while(<FILE>) {
                s/\{\"Package/\n\{\"Package/g;
                print "$_\n";
        }
        close FILE;
}
