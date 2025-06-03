# Correction Tool with Methylation

## Overview

The Correction Tool is designed to integrate methylation information into genomic bins. It automates the process by calling several tools and scripts to generate new bins enriched with methylation data.

## Installation

To set up the required environment, it is recommended to create a conda environment with the following command:

```bash
wget https://raw.githubusercontent.com/Adrinavapau/Correction-Tool/main/environment_clean.yml
conda env create -f environment_clean.yml
```

This command installs all necessary dependencies for the proper functioning of the tool.

## Usage

The main script to run is `correction_tool.sh`. This script automates the integration of methylation data into genomic bins. However, the way you run it significantly impacts what outputs you receive and how you should proceed.

To display the help message and usage instructions, run:

```bash
cd CorrectionTool
./correction_tool.sh -h
```

### Basic Usage Format

```bash
cd CorrectionTool
./correction_tool.sh [-s] [-t] [-c] <bins_dir> <SMRT_dir> <assembly_fasta>
```

### Optional Flags

- `-h` : Show the help message and exit.
- `-s` : Replace underscores (`_`) of contigs with equals signs (`=`) in contig names within `.gff` files (contigs names can't have "_").
- `-t` : Handle infinite (`inf`) values in clustering if you are using SMRT version 25.1.
- `-c` : **Not recommended** — runs default clustering and binning automatically.

---

### Why You Should Avoid `-c`

The `-c` option uses a default clustering method with fixed parameters. This may work in some cases but is generally **not reliable** because:

- Methylation patterns differ between organisms, samples, and sequencing conditions.
- Fixed parameters may overfit or underfit your data.
- Poor clustering can result in misleading bins and incorrect biological interpretation.

---

### Required Arguments

- `bins_dir` : Path to the directory containing the original bins.
- `SMRT_dir` : Path to the SMRT Link output directory.
- `assembly_fasta` : Path to the assembled FASTA file (e.g., from Hifiasm or Flye).

---

### Recommended Workflow (Manual Clustering)

If you **do not** use the `-c` option, the script will generate **two output files**, but **not the bins**:

- `summary.csv`: Contains the count of methylated motifs per contig.
- `resultados.csv`: Contains the total count of each motif per contig.

These files are essential for **manual clustering**, which is **strongly recommended** because methylation patterns vary widely between datasets. Default parameters may lead to incorrect or suboptimal bin clustering.

#### Steps for Manual Clustering:

1. **Normalize the data**: Divide the values in `summary.csv` by the corresponding values in `resultados.csv`. This gives you the methylation ratio per motif per contig.

2. **Cluster the data manually** using your preferred method and parameters. This allows for tailored analysis based on the unique properties of your dataset.

3. **Create a cluster assignment file** with the following format (CSV, no header):
    ```csv
    "contig_100",1
    "contig_101",1
    "contig_102",1
    ```
    - First column: Contig names
    - Second column: Cluster IDs
    - **Important**: There must be **no header** in this file.

4. **Run the final integration step** using `finalstep.sh`:
    ```bash
    ./finalstep.sh <bins_dir> <your_cluster_file.csv> <assembly_fasta>
    ```

This step will create the new methylation-informed bins.



