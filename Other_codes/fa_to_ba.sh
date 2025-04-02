#!/bin/bash
#SBATCH -p pibu_el8            # Partition to submit to
#SBATCH --job-name=fasta_to_bam     # Job name
#SBATCH -o brossa/spades.%A_%a.out    # Standard output file
#SBATCH -e brossa/spades.%A_%a.err    # Standard error file
#SBATCH --ntasks=1             # Use one task (needed for multi-core jobs)
#SBATCH --cpus-per-task=8      # Reduce number of CPU cores to reduce memory usage

Fasta=$1

module load BWA/0.7.17-GCC-10.3.0

module load BWA-MEM2/2.2.1-GCC-10.3.0

module load SAMtools/1.13-GCC-10.3.0


fastcons=$1

fast=$2


bbmap.sh in=raw_reads.fastq ref=hifiasm_output.bp.p_ctg.gfa out=mapped_reads.sam


bwa index $fastcons      # Index the contigs
bwa mem $fastcons $fast > aligned_reads.sam   # Align the FASTQ reads to the contigs
samtools view -bS aligned_reads.sam > aligned_reads.bam        # Convert SAM to BAM
samtools sort aligned_reads.bam -o sorted_aligned_reads.bam   # Sort BAM file
