#!/bin/sh
# script to get bioproject to GSE

# scraping
perl 00getprojsample.pl \
| gzip -c > prj2gse.json.gz
