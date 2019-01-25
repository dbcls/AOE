#!/bin/sh
# script to get bioproject to GSE

aetab=$1 # gzipped AE tab file for AOE

# scraping
pigz -dc prj2gse.json.gz \
| perl 02GEOjson2AOE.pl \
| perl 02GEO-AE.pl $aetab
