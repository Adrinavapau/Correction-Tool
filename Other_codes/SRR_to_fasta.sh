#! /bin/bash
#SBATCH --partition=short
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=1000
#SBATCH --ntasks=1 --nodes=1
#SBATCH --job-name=Solucionar

module load SRA-Toolkit/2.10.9-gompi-2020b

SSR=$1

fastq-dump --gzip --split-3 --outdir /users/genomics/anavarro/fasta/rawData/4.1_GSE64622 ${SSR}

