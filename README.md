# All of gene expression (AOE)

All of gene expression (AOE) has been an index for public transcriptome database. 

The version 2 of AOE includes scripts to extract transcriptome sequencing records from Sequence Read Archive (SRA). 
Data extracted from SRA will be merged with current version of AOE(AOE1).
API for SRA data by DBCLS SRA project is fully used to generate the data.

Currently transcriptome data from NCBI GEO is not included in EBI ArrayExpress (since 2017), and we are going to integrate the data from GEO into AOE utilizing DBCLS SRA API.

## From ArrayExpress
- `01xRX2instrument_model.pl` Extract Instrument_model from SRA Experiment data.
- `01AE2REI.pl` Generate AOE tab file from  ArrayExpress mirror at DDBJ.

Output Example:

|  ID |ProjID|AEID| Description | Date | ArrayType | ArrayGroup | Technology | Instrument | NGSGroup | Organisms | Rep_organism  |
|:-----------|:-----------|:-----------|:-----------|:-----------|:-----------|:-----------|:-----------|:-----------|:-----------|:-----------|:-----------|
|1|NA|  E-DORD-69 | Translation profiling of Arabidopsis cell cultures exposed to elevated temperature and high salinity | 2010-07-07 | Agilent Arabidopsis 3 Oligo Microarray 4x44K 015059 G2519F (Gene ID version)(A-DORD-1)[24]  | Agilent | array assay | NA | NA | Arabidopsis thaliana[24]  | Arabidopsis thaliana  |

## From GEO (DBCLS SRA API)
- `00getprojsample.pl` Extract GEO associated SRA/BioProject/BioSample data from DBCLS SRA API. 
− `01GEOjson2AOE.pl` Make subset of AOE tab file from extracted json file(s). 
- `00getlistofxRX.pl` Get metadata from D/E/SRX (Experiment). 
