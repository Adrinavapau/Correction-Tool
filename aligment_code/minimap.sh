#!/bin/bash
#SBATCH -p pibu_el8            # Partition to submit to
#SBATCH --job-name=coverage     # Job name
#SBATCH -o brossa/spades.%A_%a.out    # Standard output file
#SBATCH -e brossa/spades.%A_%a.err    # Standard error file
#SBATCH --ntasks=1             # Use one task (needed for multi-core jobs)
#SBATCH --cpus-per-task=32      # Reduce number of CPU cores to reduce memory usage



rawfas=$1
fas=$2

module load minimap2/2.20-GCCcore-10.3.0


mkdir -p ${fas%hifiasm_output.bp.p_ctg.fasta}/map


minimap2 -ax map-pb --MD --secondary=no $fas $rawfas >${fas%hifiasm_output.bp.p_ctg.fasta}map/aligned_reads.sam



#minimap2 -ax map-pb $fas $rawfas >${fas%hifiasm_output.bp.p_ctg.fasta}map/aligned_reads.sam




#minimap2 -ax map-pb $rawfas $fas > ${fas%hifiasm_output.bp.p_ctg.fasta}map/mapped_reads.sam

