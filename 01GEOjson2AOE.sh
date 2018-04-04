#!/bin/sh
# script to get bioproject to GSE

aetab=$1 # gzipped AE tab file for AOE

# scraping
gzcat prj2gse.json.gz \
| perl 01GEOjson2AOE.pl \
| perl 01GEO-AE.pl $aetab
