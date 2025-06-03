#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
path <- args[1]  # The firt argument its the path where the sumary file and the result file are found
setwd(path)      # we set the working directory to the directory where teh need files are found

# This code is used to generate methylated clusters, but it uses fixed parameters. 
#I strongly recommend adapting this code to your data.

# Eliminat the working directory.
rm(list=ls())


#--------------

# open the need libarys

library(ggplot2)
library(umap)
library(Rtsne)
library(dbscan)

#--------------



# we adapt the data.
datos <- read.csv("sumary.csv",  sep = "\t") 
datos[is.na(datos)] <- 0 # We need to changes the na for 0
rownames(datos) <- datos[, 1]
datos <-datos[,-1]
row_sums <- rowSums(datos)
datos <- datos[-which(row_sums == 0), ] # if there is a contig with 0 metylation we eliminat that contig


total_motif <- read.csv("resultados.csv", header = T)

# Filter for contigs that are shared between both datasets.
common_contigs <- intersect(rownames(datos), total_motif$Contig)

# A subset of the data only for the comun contigs.
datos_comunes <- datos[common_contigs, ]
total_motif_comunes <- total_motif[total_motif$Contig %in% common_contigs, ]

# Make sure the num of rows and colums for the two datasets is the same
rownames(total_motif_comunes) <- total_motif_comunes$Contig
total_motif_comunes <- total_motif_comunes[,-1]  # Eliminar la columna de contig

cols_in_both <- intersect(colnames(datos_comunes), colnames(total_motif_comunes))
total_motif_comunes <- total_motif_comunes[, cols_in_both]
datos_comunes <- datos_comunes[, cols_in_both] 


# Start normalizing the data dividing the sumary / results

dim(datos_comunes)
dim(total_motif_comunes)

total_motif_comunes <- total_motif_comunes[rownames(datos_comunes), ]

metilados_por_total <- datos_comunes / total_motif_comunes

metilados_por_total[] <- lapply(metilados_por_total, function(x) {
  x[is.nan(x)] <- 0
  return(x)
})

inf_check <- sapply(metilados_por_total, function(x) any(is.infinite(x)))
print(inf_check)



#set.seed(123)
UMAPnormdata <- umap(metilados_por_total, n_neighbors=5, min_dist=0.8, metric="cosine")


umap_coordinates <- UMAPnormdata$layout

# Apply DBSCAN clustering (adjust eps and minPts based on your data)
dbscan_result <- dbscan(umap_coordinates,eps=2,  minPts = 5)
# Add the cluster labels to the data
metilados_por_total$Cluster <- dbscan_result$cluster


# Check how many clusters were detected
table(metilados_por_total$Cluster)


p <- ggplot(metilados_por_total, aes(x = UMAPnormdata$layout[,1], y = UMAPnormdata$layout[,2], color=as.factor(Cluster))) +
  geom_point() +
  ggtitle("UMAP Projection for Combined P1 and P2 Data") +
  theme_classic() +
  labs(color = "Cluster Group") +
  guides(color = guide_legend(ncol = 2))

# Guardar el plot
ggsave("image/UMAP_projection.png", plot = p, width = 8, height = 6, dpi = 300, create.dir = TRUE)


metilados_por_total$contig <- row.names(metilados_por_total)

contig_col <- as.data.frame(metilados_por_total$contig)
cluster_col <- as.data.frame(metilados_por_total$Cluster)

# Combine into a new dataframe
new_df <- data.frame(contig = contig_col[,1], cluster = cluster_col[,1])

# metilados_por_total$contig <- rownames(metilados_por_total)
file_path <- "Methyl_clust.csv"

write.table(new_df, file = file_path, row.names = FALSE, col.names = FALSE, sep = ",")
