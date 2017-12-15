#!/bin/sh
# script to get bioproject to GSE

# scraping
perl 00getprojsample.pl \
| pigz -c prj2gse.json.gz
