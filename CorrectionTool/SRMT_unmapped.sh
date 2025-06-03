#!/bin/bash
#SBATCH --job-name=cotextprove        # Nombre del trabajo
#SBATCH -p pibu_el8                   # Partición donde se ejecuta
#SBATCH -o co.%A_%a.out               # Archivo de salida estándar
#SBATCH -e co.%A_%a.err               # Archivo de error estándar

# This script is to found all the motif that SMRT link tell that exist.
# But dosen't really exist, to do this we take the motif and the contex of each motif 
# and we aling each contex to teh assembled fasta in which we have the contigs

cd $1

# Input BED file
BED_FILE="motifs.bed"

# Output FASTA file
FASTA_FILE="output.fasta"

# Reference genome FASTA file
REFERENCE_FASTA="final_assembly.fasta"

# Alignment output SAM file
OUTPUT_SAM="alignment.sam"

# Output file for unmapped reads
UNMAPPED_READS="unmapped_reads.sam"

# Remove existing FASTA file if it exists
rm -f "$FASTA_FILE"

# Generate FASTA from BED file
declare -A read_contig_map  # Associative array to store expected contig names
while IFS=$'\t' read -r contig start end dot score strand kinModCall mod_type dot2 details; do
    # Extract context sequence
    context=$(echo "$details" | grep -oP 'context=\K[^;]+')
    # Use contig and position as the identifier
    identifier="${contig}_${start}_${end}"

    # Store the expected contig name
    read_contig_map["$identifier"]="$contig_$start_$end"

    # Append to FASTA file
    echo ">$identifier" >> "$FASTA_FILE"
    echo "$context" >> "$FASTA_FILE"
done < "$BED_FILE"


# Align the generated FASTA file to the reference genome using BWA aln with zero mismatches allowed (-n 0)
# Generate SAM file using bwa samse
set -e  # stop on error
bwa index final_assembly.fasta
wait
bwa aln -n 0 "$REFERENCE_FASTA" "$FASTA_FILE" > alignment.sai
bwa samse "$REFERENCE_FASTA" alignment.sai "$FASTA_FILE" > alignment.sam


# Extract unmapped reads (reads with flag 4) into a separate file
samtools view -f 4 alignment.sam > $UNMAPPED_READS


# Check for contig mismatches in mapped reads
grep -v '^@' "$OUTPUT_SAM" | while IFS=$'\t' read -r read_name flag mapped_contig rest; do
    # Ignore unmapped reads (flag 4 already handled)
    if [[ "$flag" -ne 4 ]]; then
	base_name=$(echo "$read_name" | cut -d'_' -f1)
#	echo $mapped_contig $base_name
        if [[ "$mapped_contig" != "$base_name" ]]; then
	        #echo "mapped_contig: $mapped_contig"
		#echo "base name: $base_name"
		echo -e "$read_name\t$flag\t$mapped_contig\t$rest" >> "$UNMAPPED_READS"
        fi
    fi
done



