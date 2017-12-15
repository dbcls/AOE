#!/bin/sh
# script to get metadata from DBCLS SRA API

# scraping
perl 00getlistofxRX.pl #scraping 
# fix line break
perl -i~ -pe 's/\{\"EXPERIMENT/\n\{\"EXPERIMENT/g' xRX.json \
# 
pigz xRX.json
