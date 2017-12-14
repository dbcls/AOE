#!/bin/sh
# script to get bioproject to GSE

# scraping
perl 00getprojsample.pl #scraping
# fix line break
perl -pe 's/\{\"Package/\n\{\"Package/g' prj2gse.json \
#
pigz prj2gse.json

# old code
# perl 00parseprjgse.pl |  pigz -c > PRJ2GSE.txt.gz
