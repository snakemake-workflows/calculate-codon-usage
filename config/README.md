## Workflow overview

This workflow is a best-practice workflow for calculating codon usage on coding sequences, including the RSCU (relative synonymous codon usage).
The initial version of this workflow restricts analysis to the coding sequences of MANE_select transcripts, thus implicitly restricting the workflow to human codon usage.
But it could be generalized further for other species, if a representative transcript for each protein coding gene can be chosen programatically.
In addition, the workflow also calculates the codon usage of all (human) ribosomal genes, whose identifiers are retrieved from these two curated list on HGNC:

* small ribosomal subunit genes: https://www.genenames.org/cgi-bin/genegroup/download?id=728&type=node
* large ribosomal subunit genes: https://www.genenames.org/cgi-bin/genegroup/download?id=729&type=node

Any generalization would need to make this output optional or find a programmatic way to get this list of genes for other species.

The workflow is built using [snakemake](https://snakemake.readthedocs.io/en/stable/) and consists of the following steps:
1. Download the full CDS (coding sequence) reference from Ensembl.
2. Download the lists of small and large ribosomal subunit genes.
3. Get a full list of canonical transcripts from Ensembl, with MANE_select annotations, from Ensembl BioMart.
4. Filter this to a list of all Ensembl IDs for MANE_select transcripts.
5. Filter the CDS reference to just the MANE_select transcripts.
6. Filter that MANE_select CDS reference further down to ribosomal genes.
7. Calculate the RSCU values for the full MANE_select CDS set and the ribosomal MANE_select CDS set.

The RSCU (relative synonymous codon usage) calculation uses the formula introduced by Sharp et al. (1986), namely:

```math
RSCU_{ij} = \frac{x_{ij}}{\frac{1}{n_i} \sum_{j=1}^{n_i} x_{ij}}
```

To cite the paper:

> $x_{ij}$ is the number of occurrences of the $j$ th codon for the $i$ th amino acid, which is encoded by $n_i$ synonymous codons. (More simply RSCU is the observed number of occurrences divided by that expected if usage of synonymous codons was uniform).

> Sharp, P. M.; Tuohy, T. M. F.; Mosurski, K. R. Codon Usage in Yeast: Cluster Analysis Clearly Differentiates Highly and Lowly Expressed Genes. Nucleic Acids Res 1986, 14 (13), 5125–5143. https://doi.org/10.1093/nar/14.13.5125

## Running the workflow

This workflow does not need any input data.
Everything can be configured in the `config/config.yaml` file, which contains explanatory comments.