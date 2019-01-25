#!/bin/sh

# extract bioprjID from SRA not in GEOAE 
pigz -dc xRX2instrument_model.txt.gz \
| cut -f2 \
| grep ^PRJ \
| sort -u \
> bioprj_RNAseq.txt

# extract bioprjID from AOE2 set
zgrep ^PRJ AOE2-tab2.txt.gz \
| cut -f 1 \
| sort -u \
> bioprj_AOE2.txt

# make allset
sort -u bioprj_AOE2.txt bioprj_RNAseq.txt \
| sort -u \
> bioprj_all.txt

# make bioprj_RNAseq unique set
diff bioprj_AOE2.txt bioprj_all.txt \
| grep ^\> \
| cut -d' ' -f 2 \
> bioprj_RNAseq-uniq.txt

#
# retrive json
perl 00getprojbyid.pl \
< bioprj_RNAseq-uniq.txt \
| pigz -c \
> bioprj_RNAseq-uniq.json.gz
