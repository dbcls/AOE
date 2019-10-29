#!/bin/sh
# script to get metadata from DBCLS SRA API

# scraping
perl 00getlistofxRX.pl \
| gzip -c > xRX.json.gz
