log <- file(snakemake@log[[1]], open = "wt")
sink(log)
sink(log, type = "message")

library(tidyverse)
library(seqinr)

all_cds <- read.fasta(file = snakemake@input[["fa_gz"]])

# use seqinr uco and map it to every CDS in the input fasta file
rscu <- lapply(all_cds, uco, as.data.frame = TRUE) |>
    # turn into tidyverse tibble
    enframe() |>
    # unnest the value column which contains its own data frame
    unnest(value) |>
    # reduce to the counts (per codon, per CDS)
    select(name, codon, eff) |>
    # pivot to have one entry line per CDS for easier summing up
    pivot_wider(names_from = "codon", values_from = "eff") |>
    # sum up all the codon counts over all CDS entries
    summarise(across(!name, sum)) |>
    # make it a tidy count table with one row per codon
    pivot_longer(everything(), names_to = "codon", values_to = "count") |>
    # get the amino acid for each codon for grouping
    mutate(amino_acid = map(codon, \(x) translate(s2c(x)))) |>
    # unnest resulting list column
    unnest(amino_acid) |>
    # sum up codon counts per amino acid
    add_count(amino_acid, wt = count, name = "codon_counts_per_amino_acid") |>
    # also get the number of synonymous codons per amino acid
    add_count(amino_acid, name = "synonymous_codons_per_amino_acid") |>
    mutate(
        # finally calculate the RSCU value, following the original definition
        # on page 5127 of:
        # Paul M. Sharp, Therese M.F. Tuohy, Krzysztof R. Mosurski, Codon usage in yeast: cluster analysis clearly differentiates highly and lowly expressed genes, Nucleic Acids Research, Volume 14, Issue 13, 11 July 1986, Pages 5125–5143, https://doi.org/10.1093/nar/14.13.5125
        # also reproduced in equation 3 here, for quicker reference with a
        # direct section link:
        # https://academic.oup.com/dnaresearch/article/15/6/357/513030?login=false#7971554
        rscu = count /
            ((1 / synonymous_codons_per_amino_acid) *
                codon_counts_per_amino_acid)
    )

write_tsv(rscu, file = snakemake@output[["rscu"]])
