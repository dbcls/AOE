#!/bin/sh
# script to get bioproject to GSE

perl 00getprojsample.pl #scraping 

perl -pe 's/\{\"Package/\n\{\"Package/g' prj2gse.json \
| perl 00parseprjgse.pl \
| pigz -c \
> PRJ2GSE.txt.gz
