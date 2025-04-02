#!/bin/bash
#SBATCH -p pshort_el8            # Partition to submit to
#SBATCH --job-name=binning     # Job name
#SBATCH -o brossa/spades.%A_%a.out    # Standard output file
#SBATCH -e brossa/spades.%A_%a.err    # Standard error file
#SBATCH --ntasks=1             # Use one task (needed for multi-core jobs)
#SBATCH --cpus-per-task=16      # Reduce number of CPU cores to reduce memory usage
#SBATCH --mem=400G             # Limit memory allocation to 600 GB (adjust based on your system)

fas=$1


module load SeqKit/2.6.1

#seqkit sort -n $fas -o ${fas%hifiasm_output.bp.p_ctg.fasta}hifiasm_output.bp.p_ctg_sorted.fasta #para sortear

#sort -k1,1 $fas > ${fas%coverage.txt}sorted_coverage.txt



#(head -n 1 coverage.txt && tail -n +2 coverage.txt | sort -k1,1) > sorted_coverage.txt




