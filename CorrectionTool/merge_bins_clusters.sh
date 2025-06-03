#!/bin/bash

BIN_FILE=$1  # Us the oput form the bin_contig code as imput
CLUSTER_FILE=$2 # us the cluster from make_cluster, in case the cluster is not as neede pleas check ghithub
OUTPUT_FILE="merged_output.csv"

perl -i -pe 's/=/_/g' $CLUSTER_FILE

# Use associative arrays 
declare -A contig_to_bin
declare -A contig_to_cluster

# Load bins into an associative array
while IFS=',' read -r bin contig; do
  contig_to_bin["$contig"]="$bin"
done < "$BIN_FILE"

# Load clusters into an associative array
while IFS=',' read -r contig_raw cluster; do
  # Remove quotes and equals signs from contig names
  contig=$(echo "$contig_raw" | sed 's/[="]//g')
  contig_to_cluster["$contig"]="$cluster"
done < "$CLUSTER_FILE"

# Header
echo "contig,bin,cluster" > "$OUTPUT_FILE"

# Merge logic
# Go through all contigs from both sources
all_contigs=$(printf "%s\n" "${!contig_to_bin[@]}" "${!contig_to_cluster[@]}" | sort -u)

for contig in $all_contigs; do
  bin="${contig_to_bin[$contig]:--1}"
  cluster="${contig_to_cluster[$contig]:--1}"
  echo "$contig,$bin,$cluster" >> "$OUTPUT_FILE"
done

