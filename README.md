# Snakemake workflow: `calculate-codon-usage`

[![Snakemake](https://img.shields.io/badge/snakemake-≥8.0.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/snakemake-workflows/calculate-codon-usage/workflows/Tests/badge.svg?branch=main)](https://github.com/snakemake-workflows/calculate-codon-usage/actions?query=branch%3Amain+workflow%3ATests)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![workflow catalog](https://img.shields.io/badge/Snakemake%20workflow%20catalog-darkgreen)](https://snakemake.github.io/snakemake-workflow-catalog/docs/workflows/snakemake-workflows/calculate-codon-usage)

A Snakemake workflow for calculating codon usage on coding sequences, including the RSCU (relative synonymous codon usage), currently restricted to the human genome (see the [`config/README.md`](config/README.md) for more details).

- [Snakemake workflow: `calculate-codon-usage`](#snakemake-workflow-name)
  - [Usage](#usage)
  - [Deployment options](#deployment-options)
  - [Workflow profiles](#workflow-profiles)
  - [Authors](#authors)
  - [References](#references)

## Usage

The usage of this workflow is described in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/docs/workflows/snakemake-workflows/calculate-codon-usage).
This includes a visualization of the workflow diagram and a table with all workflow parameters.

Detailed information about input data and workflow configuration can also be found in the [`config/README.md`](config/README.md).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this repository or its DOI.

## Deployment options

To run the workflow from command line, change the working directory.

```bash
cd path/to/snakemake-workflow-name
```

Adjust options in the default config file `config/config.yaml`.
Before running the complete workflow, you can perform a dry run using:

```bash
snakemake --dry-run
```

To run the workflow with test files using **conda**:

```bash
snakemake --cores 2 --sdm conda --directory .test
```

## Workflow profiles

The `profiles/` directory can contain any number of [workflow-specific profiles](https://snakemake.readthedocs.io/en/stable/executing/cli.html#profiles) that users can choose from.
The [profiles `README.md`](profiles/README.md) provides more details.

## Authors

- David Lähnemann
  - German Cancer Consortium (DKTK), partner site Essen-Düsseldorf, A partnership between DKFZ and University Hospital Essen
  - https://orcid.org/0000-0002-9138-4112
- Muhammad Murad
  - German Cancer Consortium (DKTK), partner site Essen-Düsseldorf, A partnership between DKFZ and University Hospital Essen
  - https://orcid.org/0000-0001-6030-5672

## References

> Sharp, P. M.; Tuohy, T. M. F.; Mosurski, K. R. Codon Usage in Yeast: Cluster Analysis Clearly Differentiates Highly and Lowly Expressed Genes. Nucleic Acids Res 1986, 14 (13), 5125–5143. https://doi.org/10.1093/nar/14.13.5125

> Köster, J., Mölder, F., Jablonski, K. P., Letcher, B., Hall, M. B., Tomkins-Tinch, C. H., Sochat, V., Forster, J., Lee, S., Twardziok, S. O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., & Nahnsen, S. Sustainable data analysis with Snakemake. F1000Research, 10:33, 10, 33, **2021**. https://doi.org/10.12688/f1000research.29032.2.