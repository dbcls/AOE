#! /bin/sh
#script to generate bioproject (PRJ) to GEO Series (GSE) relationships from scrapped JSON

gzip -dc prj2gse.json.gz \
| perl 00parseprjgse.pl \
| gzip -c > PRJ2GSE.txt.gz
