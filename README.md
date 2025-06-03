# Correction Tool with Methylation

## Overview

The Correction Tool is designed to integrate methylation information into genomic bins. It automates the process by calling several tools and scripts to generate new bins enriched with methylation data.

## Installation

To set up the required environment, it is recommended to create a conda environment with the following command:

```bash
conda create -n Correction_tool -c bioconda -c conda-forge -c defaults r-base=4.3 r-essentials r-matrix r-mass r-ggplot2 r-reticulate r-rtsne r-umap r-mgcv r-dbscan r-rspectra checkm2 bedops gffread emboss
```

This command installs all necessary dependencies for the proper functioning of the tool.

## Usage

The main script to run is `correction_tool.sh`. This script calls all the necessary tools and scripts to create new bins containing methylation information. Each component includes a brief explanation of its role.

To display the help message and usage instructions, run:

```bash
./correction_tool.sh -h
```

The usage format is:

```bash
./correction_tool.sh [-s] <bins_dir> <SMRT_dir> <assembly_fasta>
```

## Help Message Displayed by the Script

