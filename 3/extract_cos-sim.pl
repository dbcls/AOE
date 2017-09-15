#!/usr/bin/perl
# simple code to extract cos-sim values
# usage: cat result_sample.txt| perl extract_cos-sim.pl SRR771372 |sort -k2 -rn|less

my $id = shift(@ARGV);
my $i = 0;

$line = <STDIN>;
foreach my $srrid (split(/\t/,$line)) {
        if($srrid eq $id) {
                #print "$i\t$id\n";
                last;
        }
        $i++;
}
while(<STDIN>) {
        chomp;
        my($srrid,@value) = split(/\t/);
        print "$srrid\t$value[$i-1]\n";
}
