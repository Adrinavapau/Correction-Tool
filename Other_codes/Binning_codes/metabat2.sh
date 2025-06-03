#!/bin/bash
#SBATCH -p pibu_el8            # Partition to submit to
#SBATCH --job-name=binning     # Job name
#SBATCH -o brossa/spades.%A_%a.out    # Standard output file
#SBATCH -e brossa/spades.%A_%a.err    # Standard error file
#SBATCH --ntasks=1             # Use one task (needed for multi-core jobs)
#SBATCH --cpus-per-task=16      # Reduce number of CPU cores to reduce memory usage
#SBATCH --mem=400G             # Limit memory allocation to 600 GB (adjust based on your system)

fas=$1
cove=$2

eval "$(/data/users/anavarropau/miniconda3/bin/conda shell.bash hook)"


# SI SALTA ERROR DE SORT SACAR LOS #

module load SAMtools/1.13-GCC-10.3.0


samtools coverage $cove > ${cove%aligned_reads.sorted.bam}coverage.txt

(head -n 1 ${cove%aligned_reads.sorted.bam}coverage.txt && tail -n +2 ${cove%aligned_reads.sorted.bam}coverage.txt | sort -k1,1) > ${cove%aligned_reads.sorted.bam}sorted_coverage.txt


#metabat2 -i $fas -a ${cove%aligned_reads.sorted.bam}coverage.txt -o ${cove%aligned_reads.sorted.bam}bins_dir/bin 


metabat2 -i $fas -a ${cove%aligned_reads.sorted.bam}sorted_coverage.txt -o ${cove%aligned_reads.sorted.bam}bins_dir/bin # with the sorted file 





