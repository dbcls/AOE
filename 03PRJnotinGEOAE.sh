#!/bin/sh

# extract bioprjID from SRA not in GEOAE 
gzip -dc xRX2instrument_model.txt.gz \
| cut -f2 \
| grep ^PRJ \
| sort -u \
> bioprj_SRA.txt

# extract bioprjID from AOE2 set
zgrep ^PRJ AOE2-tab2.txt.gz \
| cut -f 1 \
| sort -u \
> bioprj_AOE2.txt

# make allset
sort -u bioprj_AOE2.txt bioprj_SRA.txt \
| sort -u \
> bioprj_all.txt

# make bioprj_RNAseq unique set
diff bioprj_AOE2.txt bioprj_all.txt \
| grep ^\> \
| cut -d' ' -f 2 \
> bioprj_SRA-uniq.txt

#
# retrive json
# and make AOE3 tab
perl 00getprojbyid.pl \
< bioprj_SRA-uniq.txt \
| grep 'Transcriptome or Gene expression' \
| perl 03mkAOEtab.pl \
> AOE3-tab.txt
