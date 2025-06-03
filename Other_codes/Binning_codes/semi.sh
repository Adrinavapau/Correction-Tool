#!/bin/bash
#SBATCH -p pibu_el8            # Partition to submit to
#SBATCH --job-name=binning       # Job name
#SBATCH -o brossa/spades.%A_%a.out    # Standard output file
#SBATCH -e brossa/spades.%A_%a.err    # Standard error file
#SBATCH --ntasks=1               # Use one task (needed for multi-core jobs)
#SBATCH --cpus-per-task=16       # Reduce number of CPU cores to reduce memory usage
#SBATCH --mem=400G               # Limit memory allocation to 600 GB (adjust based on your system)



fas=$1
bam=$2

eval "$(/data/users/anavarropau/miniconda3/bin/conda shell.bash hook)"

# sed 's/\t/,/g' $cove > ${cove%coverage.txt}coverage.csv

#SemiBin2 generate_sequence_features_single \
#    -i $fas \
#    -b $bam \
#    -o ${bam%aligned_reads.sorted.bam}semi/contig_output \
#    --verbose


#SemiBin2 train_self \
#    --data ${bam%aligned_reads.sorted.bam}semi/contig_output/data.csv \
#    --data-split ${bam%aligned_reads.sorted.bam}semi/contig_output/data_split.csv \
#    -o ${bam%aligned_reads.sorted.bam}semi/contig_output \
#    --verbose




SemiBin2 single_easy_bin \
        --environment human_gut \
        --sequencing-type long_read \
        -i $fas \
        -b $bam \
        -o ${bam%aligned_reads.sorted.bam}semi/output



#SemiBin2 single_easy_bin \
#    -i $fas \
#    --environment global \
#    --b $bam  \
#    -o ${bam%aligned_reads.sorted.bam}semi/output \
#    --verbose


#    --model ${bam%aligned_reads.sorted.bam}semi/contig_output/model.h5 \




