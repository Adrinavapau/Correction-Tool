#!/bin/bash
#SBATCH -p pibu_el8            # Partition to submit to
#SBATCH --job-name=coverage     # Job name
#SBATCH -o brossa/spades.%A_%a.out    # Standard output file
#SBATCH -e brossa/spades.%A_%a.err    # Standard error file
#SBATCH --ntasks=1             # Use one task (needed for multi-core jobs)
#SBATCH --cpus-per-task=16      # Reduce number of CPU cores to reduce memory usage


module load FastQC/0.11.9-Java-11



fastq=$1


mkdir -p ${fastq%.hifi_reads_sorted.fastq}/qc_reports

fastqc -o ${fastq%.hifi_reads_sorted.fastq}/qc_reports $fastq




