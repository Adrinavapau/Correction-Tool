#!/bin/bash
#SBATCH --job-name=cluster_binning_reassign
#SBATCH -p pibu_el8
#SBATCH -o cluster_reassign.%A.out
#SBATCH -e cluster_reassign.%A.err

# Input FASTA
fasta_file=$1

# Merged CSV file
csv_file="merged_output.csv"

# Output directory
output_dir="NEW_bins"
rm -r "$output_dir"
mkdir -p "$output_dir"

# --- Step 1: Generate bins for contigs with clusters with out -1 ---

tail -n +2 "$csv_file" | while IFS=',' read -r contig bin cluster; do
    # clean the quotation marks 
    contig=$(echo "$contig" | sed 's/"//g')
    bin=$(echo "$bin" | sed 's/"//g')
    cluster=$(echo "$cluster" | sed 's/"//g')

    # Proces the contigs which dose not have a clustre -1
    if [[ "$cluster" != "-1" ]]; then
        output_file="${output_dir}/bin.${cluster}.fa"

        # Extract the Fasta seq and add in to the corresponding file 
        awk -v contig=">$contig" '
        BEGIN {found=0}
        $0 == contig {found=1; print; next}
        found && /^>/ {found=0}
        found {print}
        ' "$fasta_file" >> "$output_file"
    fi
done

echo "FASTA bins generados para contigs con cluster válido."

# --- Step 2: Reassaing contigs with cluster = -1 to the bin with the majority of the contigs in the origuinal bin ---

# Temporal file of contigs with out cluster 
awk -F',' 'NR>1 && $3 == "-1" {print $1","$2}' "$csv_file" > unclustered.csv

# Crear a file with the valid ones
awk -F',' 'NR>1 && $3 != "-1" {print $1","$2","$3}' "$csv_file" > clustered.csv

# Reassaing the no clustered contigs
while IFS=',' read -r contig unclustered_bin; do
    # Look fo the contigs of the origuinal bin 
    grep ",${unclustered_bin}," clustered.csv > tmp_bin_group.csv

    # Count the majority of contigs based on where they were assigned.
    cluster=$(cut -d',' -f3 tmp_bin_group.csv | sort | uniq -c | sort -nr | head -n1 | awk '{print $2}')

    # Determine to which bin goes
    if [[ -n "$cluster" ]]; then
        output_file="${output_dir}/bin.${cluster}.fa"
    else
        output_file="${output_dir}/bin.unassigned.fa"
    fi

    # Extract the Fasta seq and add in to the corresponding file
    awk -v contig=">$contig" '
    BEGIN {found=0}
    $0 == contig {found=1; print; next}
    found && /^>/ {found=0}
    found {print}
    ' "$fasta_file" >> "$output_file"
done < unclustered.csv

# Clean tmp files
rm -f tmp_bin_group.csv clustered.csv unclustered.csv

checkm2 predict --threads 30 --force --input NEW_bins/*.fa --output-directory checkm2_output


echo "Reassignation done."
