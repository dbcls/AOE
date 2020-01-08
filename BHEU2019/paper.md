---
title: "TogoEx: the integration of gene expression data"
tags:
  - gene expression
authors:
  - name: Hidemasa Bono
    orcid: 0000-0003-4413-0651
    affiliation: 1
  - name: Takeya Kasukawa
    orcid: 0000-0001-5085-0802
    affiliation: 2
affiliations:
  - name: DBCLS, Japan
    index: 1
  - name: RIKEN, Japan
    index: 2
date: 08 January 2020
bibliography: paper.bib
---

# State the problem you worked on

- Current available metadata for gene expression data is not sufficient enough to re-use.
- Human resources are lacking to tackle the integration of gene expression data.

# Give the state-of-the art/plan

Gene expression data have been archived in public repositories, the NCBI Gene Expression Omnibus (GEO; https://www.ncbi.nlm.nih.gov/geo/) and the EBI ArrayExpress (AE; https://www.ebi.ac.uk/arrayexpress/). Unlike the International Nucleotide Sequence Database (https://www.insdc.org/), these two databases have not been exchanging data with each other. Furthermore, the DNA DataBank of Japan (DDBJ) in the National Institute of Genetics started a similar repository called the Genomic Expression Archive (GEA; https://www.ddbj.nig.ac.jp/gea/) in 2018. Hence there is a need for integration of these public gene expression databases.
Thus, we have maintained an index of these public gene expression databases, called All Of gene Expression (AOEï¼› https://aoe.dbcls.jp/en) to integrate gene expression data and make them all searchable together.

During the DBCLS/NDBC 2019 BioHackathon, we worked on the refinement of Reference Expression Dataset (RefEx; https://refex.dbcls.jp/?lang=en) for gene expression analysis in order to make gene expression data reusable. The gene expression data to integrate in the hackathon were mainly project-based, and those included those of FANTOM5[@Kawaji:2017], GTEx v8, fly and rice.

We felt that users wanted to reuse data from FANTOM6 project which was just published with bioRxiv preprint (https://doi.org/10.1101/700864; http://fantom.gsc.riken.jp/6/).ã€€The data consists of the large-scale expression profiles after the knockdown of long non-coding RNAs (lncRNAs) using several technologies including antisense oligo (ASO) and siRNA.

Thus, we tackled the FANTOM6 data in the ELIXIR BioHackathon-Europe 2019, and decided implementation plans and schedules to implement a system for the search interface.

# Describe what you have done/results starting with the working group created...

1. Clarified what is needed in the data production for gene expression data collection including FANTOM, GTEx and Human Cell Atlas. Especially, we eargely require well-annotated metdata to expression data for their reusability and human resoruces for the curation of the metadata.
2. Discussed how to reuse Cap Analysis of Gene Expression (CAGE) data for lncRNA knockdown from FANTOM6. The knockdown expression profiles can potentially be (re)used for computational analysis to identify related (knock-down) genes to any types of biological stimulations (experimental treamtments).
3. Designed the implementation to search an expression profile against data matrix above for associatable lncRNA. The search can hopefully be achieved by using an enrichment-like method with upreguated/downregulated genes in a different experiment.

# Conclusion

After a stimulus discussion in the ELIXIR BioHackathon-Europe 2019, we could successfully make a plan to reuse the CAGE data for lncRNA knockdown in FANTOM6 project.
While the Reference Expression dataset in DBCLS (RefEx) currently includes transcriptome data for normal tissues and cell lines, we discussed how to reuse transcriptome data for knockdown.
This is only a starting point to reuse public knockdown data, but these 'reuse-ready' data can be useful for molecular biology in the near future.

# Future work

We will continue current effort to integrate gene expression data to increase the usability of these data in life science.

By gathering and then curating gene expresion datasets, those data not in NCBI GEO, EBI AE and DDBJ GEA can be included in AOE. We will also work for it.

# Jupyter notebooks created

We tried to code with Jupyter Notebook in bash kernel, but it seems that CWL is suitable for our purpose. We are willing to use BioHackrXiv to publish our activity in the ELIXIR BioHackathon-Europe 2019.

# References

- Functional Annotation of Human Long Non-Coding RNAs via Molecular Phenotyping. doi: https://doi.org/10.1101/700864
- All of gene expression (AOE): an integrated index for public gene expression databases. doi: https://doi.org/10.1101/626754
- RefEx, a reference gene expression dataset as a web tool for the functional analysis of genes. doi: https://doi.org/10.1038/sdata.2017.105
- The FANTOM5 project (collection). https://www.nature.com/collections/fantom5

# Acknowledgement

This work was funded by ELIXIR, the research infrastructure for life-science data, as part of the ELIXIR BioHackathon-Europe 2019.
