#!/bin/bash
#SBATCH -p pshort_el8            # Partition to submit to
#SBATCH --job-name=copiardir     # Job name
#SBATCH -o brossa/copy.%A_%a.out    # Standard output file
#SBATCH -e brossa/copy.%A_%a.err    # Standard error file


sam=$1

mkdir -p ${sam%map}samples/

cp -r $sam/*/  ${sam%map}samples/

rm -r ${sam%map}samples/max/output_folder/

rm ${sam%map}samples/max/output_folder.log

rm ${sam%map}samples/max/output_folder.marker
rm ${sam%map}samples/max/output_folder.marker_of_each_bin.tar.gz
rm ${sam%map}samples/max/output_folder.noclass
rm ${sam%map}samples/max/output_folder.summary
rm ${sam%map}samples/max/output_folder.tooshort
rm ${sam%map}samples/max/*.seed
rm -r ${sam%map}samples/semi

cp -r $sam/semi/output/output_bins ${sam%map}samples/semi








