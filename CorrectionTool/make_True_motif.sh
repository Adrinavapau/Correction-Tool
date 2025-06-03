#!/bin/bash
#SBATCH --job-name=filteringgff       # Nombre del trabajo
#SBATCH -p pibu_el8                   # Partición donde se ejecuta
#SBATCH -o hobtenir.out               # Archivo de salida estándar
#SBATCH -e hobtenir.err               # Archivo de error estándar

# This code what it makes is to correct the gff by filtering the unmapped motif
# It's importan to know that this code it will only work with the contigs names of the hifiasm and the from SMRT link

cd $1

# The unmapped motif extracted for the other code
INPUT_SAM="unmapped_reads.sam"

# eliminat the gff in case it already exist
rm -f no_existend.gff

# in this while we take all the motif which dosen't exist, we check if they are in the both strand 
while IFS=$'\t' read -r read_name flag mapped_contig rest o i u y t context d; do

        base_read_name=$(echo "$read_name" | cut -d'_' -f1)
	star=$(echo "$read_name" | cut -d'_' -f2)
        end=$(echo "$read_name" | cut -d'_' -f3)
	if [[ "$flag" -eq 16 ]]; then
		context=$(echo "$context" | rev | tr 'ACGTNRYKMSWBDHV' 'TGCANYRMKSWVHDB')
	
	fi
	
        grep "${base_read_name}.*${end}.*${context}" filtered_motifs.gff >> no_existend.gff
 

done < $INPUT_SAM


# comper the gff and the lines that maches are remubet from the final gff
awk 'NR==FNR {exclude[$1"\t"$4"\t"$5"\t"$9]; next} !($1"\t"$4"\t"$5"\t"$9 in exclude)' no_existend.gff filtered_motifs.gff > filtered_motifs_filtered.gff


