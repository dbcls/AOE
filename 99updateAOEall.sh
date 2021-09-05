#!/bin/sh
# update AOE index
# By Hidemasa Bono <bono@dbcls.rois.ac.jp>
#
# Run on dtn4 for accesssing FTP directories

aoedir=/home/bono/AOE
github=/home/bono/AOE/AOE

### level1&2
# FTP get from AE 


# get RNA-seq entries in SRA using DBCLS SRA API
# to produce xRX.json.gz
cd ${github}; sh 00getlistofxRX.sh 

# fetch data in GEO using DBCLS SRA API
# to produce prj2gse.json.gz and PRJ2GSE.txt.gz
echo "running 00getprojsample.sh"
sh 00getprojsample.sh

# parse data in GEO 
echo "running 00parseprjgse.sh"
sh 00parseprjgse.sh

# get SRA_Accessions.tab & compress
echo "getting SRA_Accessions.tab"
#lftp -c 'open ftp.ncbi.nlm.nih.gov/sra/reports/Metadata && pget -n 8 SRA_Accessions.tab'
curl -O https://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab
gzip SRA_Accessions.tab

# extract instrument model to produce xRX2instrument_model.txt.gz
echo "01xRX2instrument_model.sh"
sh 01xRX2instrument_model.sh

# copy PRJ2GSE.txt.gz & xRX2instrument_model.txt.gz to ddbj sc
#scp PRJ2GSE.txt.gz gw.ddbj.nig.ac.jp:AOE/
#echo "copy PRJ2GSE.txt.gz & xRX2instrument_model.txt.gz to other directory"
mv PRJ2GSE.txt.gz ${aoedir}
cp xRX2instrument_model.txt.gz ${aoedir}

## In DDBJ sc, run
echo "update_aoe2.sh"
cd ${aoedir}; sh update_aoe2.sh

# copy back to local machine
#scp gw.ddbj.nig.ac.jp:AOE/AOE2-tab.txt.gz .
echo "copy back to working directory"
cp ${aoedir}/AOE2-tab.txt.gz ${github}

# populate the information
echo "populate the information"
cd ${github}; sh 02GEOjson2AOE.sh AOE2-tab.txt.gz > AOE2-tab2.txt

### level3
# get entries not in GEO but in SRA (RNA-seq)
echo "run level3"
sh 03PRJnotinGEOAE.sh

# merge AOE2 + AOE3
echo "merge AOE2 & AOE3"
today=$(date "+%y%m%d")
cat AOE2-tab2.txt AOE3-tab.txt | gzip -c > ${today}.txt.gz

## copy to AWS EC2
echo "copy to AWS EC2"
scp ${today}.txt.gz aoe2018:

## on AWS EC2 update AOE
# cd /var/www/html/aoe; sh clear_core.sh
# python dataImport.py file_path
