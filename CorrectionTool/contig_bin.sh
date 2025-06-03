#!/bin/bash

# Usage: ./bin_contigs.sh /path/to/bins > output.csv

INPUT_DIR="$1"

# Check if the input is what we are looking for.
if [ -z "$INPUT_DIR" ]; then
  echo "Usage: $0 <directory_with_bins>"
  exit 1
fi

# Loop through all .fa or .fasta files in the directory
for BIN in "$INPUT_DIR"/*.fa ; do
  # Skip if no match
  [ -e "$BIN" ] || continue
  BIN_NAME=$(basename "$BIN")
  BIN_NAME="${BIN_NAME%.fa}"
 
  # Extract contig names (lines starting with >)
  grep "^>" "$BIN" | while read -r LINE; do
    CONTIG=$(echo "$LINE" | sed 's/^>//' | awk '{print $1}')
    echo "${BIN_NAME},${CONTIG}"
  done
done

