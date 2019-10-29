#!/bin/sh
#
# update AOE index
#

### level1&2
# FTP get from AE

# get RNA-seq entries in SRA using DBCLS SRA API
# to produce xRX.json.gz
sh 00getlistofxRX.sh 

# fetch data in GEO using DBCLS SRA API
# to produce prj2gse.json.gz and PRJ2GSE.txt.gz
sh 00getprojsample.sh

# parse data in GEO 
sh 00parseprjgse.sh

# get SRA_Accessions.tab & compress
lftp -c 'open ftp.ncbi.nlm.nih.gov/sra/reports/Metadata && pget -n 8 SRA_Accessions.tab'
pigz SRA_Accessions.tab

# extract instrument model to produce xRX2instrument_model.txt.gz
sh 01xRX2instrument_model.sh

# copy PRJ2GSE.txt.gz & xRX2instrument_model.txt.gz to ddbj sc
#scp PRJ2GSE.txt.gz gw.ddbj.nig.ac.jp:AOE/
mv PRJ2GSE.txt.gz ~/AOE/
#scp xRX2instrument_model.txt.gz gw.ddbj.nig.ac.jp:AOE/
mv xRX2instrument_model.txt.gz ~/AOE/

## In DDBJ sc, run
cd ~/AOE; sh update_aoe2.sh

# copy back to local machine
#scp gw.ddbj.nig.ac.jp:AOE/AOE2-tab.txt.gz .
cp ~/AOE/AOE2-tab.txt.gz ~/AOE/AOE/

# populate the information
cd ~/AOE/AOE
sh 02GEOjson2AOE.sh AOE2-tab.txt.gz > AOE2-tab2.txt

### level3
# get entries not in GEO but in SRA (RNA-seq)
sh 03PRJnotinGEOAE.sh

# merge AOE2 + AOE3
today=$(date "+%y%m%d")
cat AOE2-tab2.txt AOE3-tab.txt | gzip -c > ${today}.txt.gz

## copy to AWS EC2
scp ${today}.txt.gz aoe2018:

## on AWS EC2 update AOE
# cd /var/www/html/aoe; sh clear_core.sh
# python dataImport.py file_path
