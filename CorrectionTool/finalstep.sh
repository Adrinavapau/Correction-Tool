#!/bin/bash
#SBATCH -p pibu_el8            # Partition to submit to

# This code can be use by his own.
# It need the bins and the clusterd methylation information
# with the contig name and the clusters, there is an exaple in the guithub :
# It's recomended to make the cluster and the normalitzation your self.

bins_dir="$1"
Methyl_clust="$2"
Asseblefa=$3

# we store the list of contigs of each bin
echo "Generating list of contigs for each bin"
chmod +x contig_bin.sh
./contig_bin.sh $bins_dir > bins_contigs.csv
echo "finish generation"


# Generates a file which will tell for each contig what to do
echo "genarete file to identify new bins"
chmod +x merge_bins_clusters.sh
./merge_bins_clusters.sh bins_contigs.csv $Methyl_clust
echo "file generated"

# This generate the bins from the file formed in the last step
echo "generate the bins"
chmod +x from_mernge_bin.sh
./from_mernge_bin.sh $Asseblefa
echo "new vins generated"


echo "Finished successfully."


