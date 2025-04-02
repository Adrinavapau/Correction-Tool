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


mkdir -p ${cove%sorted_coverage.txt}max/output_folder

perl /data/users/anavarropau/miniconda3/bin/run_MaxBin.pl -contig $fas -abund $cove -out ${cove%sorted_coverage.txt}max/output_folder





