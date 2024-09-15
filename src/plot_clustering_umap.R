source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
infile3 <- args[3]
infile4 <- args[4]
infile5 <- args[5]
infile6 <- args[6]
infile7 <- args[7]
infile8 <- args[8]
outfile <- args[9]

# Loading
cluster1 <- as.matrix(read.table(infile1, header=FALSE))
cluster2 <- as.matrix(read.table(infile2, header=FALSE))
cluster3 <- as.matrix(read.table(infile3, header=FALSE))
cluster4 <- as.matrix(read.table(infile4, header=FALSE))

umap1 <- as.matrix(read.table(infile5, header=FALSE))
umap2 <- as.matrix(read.table(infile6, header=FALSE))
umap3 <- as.matrix(read.table(infile7, header=FALSE))
umap4 <- as.matrix(read.table(infile8, header=FALSE))

# Plot
png(outfile, width=1500, height=1500)
layout(rbind(1:2, 4:3))
plot(umap1, col=cluster1, cex=2, pch=16)
plot(umap2, col=cluster2, cex=2, pch=16)
plot(umap3, col=cluster3, cex=2, pch=16)
plot(umap4, col=cluster4, cex=2, pch=16)
dev.off()
