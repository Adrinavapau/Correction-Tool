#!/bin/bash
#SBATCH --job-name=motif        # Nombre del trabajo
#SBATCH -p pshort_el8           # Partición donde se ejecuta
#SBATCH -o fuzz.%A_%a.out       # Archivo de salida estándar
#SBATCH -e fuzz.%A_%a.err       # Archivo de error estándar

# This code uses the tool fuzznucc to count all the motifs that a contig has, taking into account the motifs found by SMRT Link.

# Extract the first colum of the csv but with out the header.
tail -n +2 motifs.csv | cut -d',' -f1 > tep.txt

# create a list of the motif and the header of the new csv
motifs=($(cat tep.txt))
echo -n "Contig" > resultados_matrix.csv
for motif in "${motifs[@]}"; do
    echo -n ",$motif" >> resultados_matrix.csv
done
echo "" >> resultados_matrix.csv

# Decler a matrix to store the counts.
declare -A motif_matrix

touch contigs_list.txt

# Execut fuzznuc for all the motif in the list.
for motif in "${motifs[@]}"; do
    fuzznuc -complement -sequence final_assembly.fasta -pattern "$motif" -rformat2 gff -outfile "result_$motif.gff"

    fuzznuc -complement -sequence final_assembly.fasta -pattern "$motif" -outfile "result_$motif.txt"

touch contigs_list.txt
    # Process the files to extract the contigs and the count of the motifs.
    while IFS= read -r line; do
        if [[ "$line" =~ ^#\ Sequence:\ ([^\ ]+) ]]; then
            contig="${BASH_REMATCH[1]}"
            echo "$contig" >> contigs_list.txt  # Store the contigs into a list
        fi
        if [[ "$line" =~ ^#\ HitCount:\ ([0-9]+) ]]; then
            hit_count="${BASH_REMATCH[1]}"
            motif_matrix["$contig,$motif"]=$hit_count
        fi
    done < "result_$motif.txt"

done

# Eliminate duplicates in the list of contigs
sort -u contigs_list.txt > unique_contigs.txt

# Start generating the matrix.
touch resultados_matrix.csv
while read -r contig; do
    echo -n "$contig" >> resultados_matrix.csv
    for motif in "${motifs[@]}"; do
        echo -n ",${motif_matrix["$contig,$motif"]:-0}" >> resultados_matrix.csv
    done
    echo "" >> resultados_matrix.csv

done < unique_contigs.txt

sed 's/_/\//g' resultados_matrix.csv > resultados.csv

# eliminate temporal files
rm tep.txt contigs_list.txt unique_contigs.txt

for motif in "${motifs[@]}"; do
    rm "result_$motif.txt"
done


for motif in "${motifs[@]}"; do
    rm "result_$motif.gff"
done


rm resultados_matrix.csv

