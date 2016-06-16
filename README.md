#AOE2.0

Scripts to extract transcriptome sequencing records from Sequence Read Archive (SRA).

- Extract IDs from metadata in SRA
	- study.prl
	- sample.prl
	- experiment.prl
- Join them
	- join.prl

- Generate list of distinct Run IDs with corresponding Experiment ID
	- experiment-run.prl

- Extract BioProjectID vs GSE ID table from Bioproject XML
	- bioproject.prl

- Extract date information
	- date.prl

The data extracted from SRA will be merged with current version of AOE index(AOE1).

Output Example:
ID	PrjID	AEID      Description     Date    ArrayType       ArrayGroup      Technology      Instrument      NGSGroup        Organisms       Rep_organism
1	NA	E-DORD-69       Translation profiling of Arabidopsis cell cultures exposed to elevated temperature and high salinity    2010-07-07      Agilent Arabidopsis 3 Oligo Microarray 4x44K 015059 G2519F (Gene ID version)(A-DORD-1)[24]      Agilent array assay     NA      NA      Arabidopsis thaliana[24]        Arabidopsis thaliana
