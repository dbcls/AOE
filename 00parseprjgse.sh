#! /bin/sh
#script to generate bioproject (PRJ) to GEO Series (GSE) relationships from scrapped JSON

pigz -dc prj2gse.json.gz \
| perl 00parseprjgse.pl \
| pigz -c > PRJ2GSE.txt.gz
