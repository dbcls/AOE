#! /bin/sh
pigz -dc prj2gse.json.gz \
| perl 00parseprjgse.pl \
| pigz -c > PRJ2GSE.txt.gz
