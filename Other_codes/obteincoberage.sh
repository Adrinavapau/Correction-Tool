#!/bin/bash
#SBATCH -p pshort_el8            # Partition to submit to
#SBATCH --job-name=coverage     # Job name
#SBATCH -o brossa/spades.%A_%a.out    # Standard output file
#SBATCH -e brossa/spades.%A_%a.err    # Standard error file
#SBATCH --ntasks=1             # Use one task (needed for multi-core jobs)
#SBATCH --cpus-per-task=32      # Adjust CPU cores if needed

bam=$1

module load SAMtools/1.13-GCC-10.3.0


samtools coverage $bam > ${bam%aligned_reads.sorted.bam}coverage.txt




# Compute per-contig average coverage (ensure tab separation)
#samtools depth -a "$bam" | awk -v OFS="\t" '{sum[$1]+=$3; count[$1]++} END {for (c in sum) print c, sum[c]/count[c]}' > "${bam%aligned_reads.sorted.bam}coverage.txt"




