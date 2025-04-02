#!/bin/bash
#SBATCH -p pibu_el8                    # Partition to submit to
#SBATCH --job-name=assemble             # Job name
#SBATCH -o brossa/spades.%A_%a.out      # Standard output file
#SBATCH -e brossa/spades.%A_%a.err      # Standard error file
#SBATCH --ntasks=1                      # Use one task (needed for multi-core jobs)
#SBATCH --cpus-per-task=32              # Reduce number of CPU cores to reduce memory usage
#SBATCH --mem=600G                      # Limit memory allocation to 600 GB (adjust based on your system)

# Get FASTA files list dynamically in each job
fasta_dir=$1

fasta_files=($fasta_dir/*.hifi_reads.fastq)

# Select the FASTA file corresponding to the current job array index
# fasta=${fasta_files[$SLURM_ARRAY_TASK_ID - 1]}
fasta=${fasta_files[$((SLURM_ARRAY_TASK_ID - 1))]}



# Define the output path
output_dir="/data/users/anavarropau/Adria/FecalHuman/prova"

# Load the hifiasm module (replace with your actual environment setup if needed)
module load hifiasm/0.16.1-GCCcore-10.3.0

# Run hifiasm with memory and thread limitations
hifiasm -o ${fasta%.hifi_reads.fastq}/hifiasm_output -t 16 $fasta
