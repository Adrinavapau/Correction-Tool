# Correction Tool with Methylation

## Overview

The Correction Tool is designed to integrate methylation information into genomic bins. It automates the process by calling several tools and scripts to generate new bins enriched with methylation data.

## Installation

To set up the required environment, it is recommended to create a conda environment with the following command:

```bash
git clone https://github.com/Adrinavapau/Correction-Tool
cd Correction-Tool/
conda env create -f environment_clean.yml
conda activate Correction_tool
checkm2 database --download
```

This command installs all necessary dependencies for the proper functioning of the tool.

## Test

**First, install SMRT Link in the SMRT Link directory.**

Then, download the data from this link into two different directories: place the bin files in one directory and the other data in another.
https://zenodo.org/records/15680286?token=eyJhbGciOiJIUzUxMiJ9.eyJpZCI6IjQxYjYzZjY3LTI0OWEtNGIyNS1hMjkwLTViZDNhMzM0MGExOCIsImRhdGEiOnt9LCJyYW5kb20iOiJhNzg4NjYwYzdhMDlhNDAyZWVjNzUwMWI1ZWU3ZDBlMyJ9.qwW1gg59mp392gFlAQqZnAMdCgPmIibGCBnZ8G2OpC9CO9r1hDCkbjtwrkIjYQM4aYsE1PIJ55xLDya6bTyjhw

The downloaded files should be the following:

   - A BAM file with raw HiFi reads.

   - The corresponding PBI index file.

   - An assembled FASTA file generated using hifiasm-meta.

   - 5 bin files which are .fa
     
Run the SMRT Link program:
```bash
cd CorrectionTool
./runMethylfromGenome.slurm merged_ccs <directoty data> <directoty SMRTlink>
```

Once you have the download the data, generate the bins. After that, you can use the correction tool:

```bash
cd CorrectionTool
./correction_tool.sh -c <bins_dir> <SMRT_out> <assembly_fasta>
```

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
./correction_tool.sh [-s] [-t] [-c] <bins_dir> <SMRT_out> <assembly_fasta>
```

### Optional Flags

- `-h` : Show the help message and exit.
- `-s` : Replace underscores (`_`) of contigs with equals signs (`=`) in contig names within `.gff` files (contigs names can't have "_").
- `-t` : Handle infinite (`inf`) values in clustering if you are using SMRT version 25.1 or earlier.
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
- `SMRT_out` : Path to the SMRT Link output directory.
- `assembly_fasta` : Path to the assembled FASTA file (e.g., from Hifiasm-meta or Flye-meta).

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

---


## Developer Guide and Code Workflow

This section explains each script used in the project and its role in the overall workflow.

**Codes marked with * can be used on their own.**

---

### `runMethylfromGenome.slurm *`
This script uses **SMRT Link tools** and is executed **before** the main script `correction_tool.sh`.  
**Requirements:**
- Raw BAM file with the reads
- PBI index of the BAM file
- Assembled FASTA (recommended to use assemblies generated by **hifiasm-meta** or **flye-meta**)

---

### `correction_tool.sh *`
This is the **main script**, responsible for executing the rest of the scripts based on the input parameters.  
**Requirements:**
- Directory containing the original bins  
- Output dir from `runMethylfromGenome.slurm` or SMRT link  
- Assembled FASTA file

---

### `SMRT_unmapped.sh`
Used as an **alternative** if SMRT Link has execution issues or the normalized data have inf values.  
This script aligns the context of motifs to detect mismatches.

---

### `make_True_motif.sh`
Also used when SMRT Link causes problems.  
It filters out motifs that did not align to their expected contigs from the original motif file.

---

### `gff2table.pl`
Summarizes the methylated motif information generated by SMRT Link.  
**Output:** `summary.csv`

---

### `new_emboss2.sh`
Uses `fuzznuc` to count the **total number of motifs** per contig.  
It considers whether motifs are palindromic or non-palindromic.  
**Output:** `resultados.csv`

---

### `make_clusters.R`
An R script that clusters the methylation information.  
**Note:** This is a **default method** and **not recommended**. It is better to cluster the data manually, as described in the **Recommended Workflow**.  
To normalize the data, divide the number of methylated motifs by the total motifs per contig.

---

### `finalstep.sh *`
This script can be used **independently** if methylation clusters have been created manually.  
**Requirements:**
- Directory of original bins  
- Cluster file (format described in **Recommended Workflow**)  
- Assembled FASTA

This script runs different tools to analyze the bins.

---

### `contig_bin.sh`
Generates a list of contigs for the original bins, showing which contig belongs to which bin.

---

### `merge_bins_clusters.sh`
Combines the information from original bins with the methylation clusters, assigning each contig to its corresponding bin.

---

### `from_merge_bin.sh`
Takes the merged data from `merge_bins_clusters.sh`, generates the final bins, and checks their quality.







