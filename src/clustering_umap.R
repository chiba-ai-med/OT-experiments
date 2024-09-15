source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
infile3 <- args[3]
infile4 <- args[4]
outfile1 <- args[5]
outfile2 <- args[6]
outfile3 <- args[7]
outfile4 <- args[8]
outfile5 <- args[9]
outfile6 <- args[10]
outfile7 <- args[11]
outfile8 <- args[12]
outfile9 <- args[13]
outfile10 <- args[14]
outfile11 <- args[15]

# Loading
source_train <- as.matrix(read.table(infile1, header=FALSE, sep=","))
P <- as.matrix(read.table(infile2, header=FALSE))
v_s <- as.matrix(read.table(infile3, header=FALSE))
rec_t_v_s <- as.matrix(read.table(infile4, header=FALSE))

# Transport
t_v_s <- t(P) %*% v_s

# k-NN Graph
knn1 <- nn2(t(source_train), k=11)$nn.idx[,2:11]
knn2 <- nn2(t(v_s), k=11)$nn.idx[,2:11]
knn3 <- nn2(t(t_v_s), k=11)$nn.idx[,2:11]
knn4 <- nn2(t(rec_t_v_s), k=11)$nn.idx[,2:11]

knn1 <- apply(knn1, 1, function(x){
	tmp <- rep(0, length=ncol(source_train))
	tmp[x] <- 1
	tmp
})

knn2 <- apply(knn2, 1, function(x){
	tmp <- rep(0, length=ncol(v_s))
	tmp[x] <- 1
	tmp
})

knn3 <- apply(knn3, 1, function(x){
	tmp <- rep(0, length=ncol(t_v_s))
	tmp[x] <- 1
	tmp
})

knn4 <- apply(knn4, 1, function(x){
	tmp <- rep(0, length=ncol(rec_t_v_s))
	tmp[x] <- 1
	tmp
})

knn1 <- t(knn1) %*% knn1
knn2 <- t(knn2) %*% knn2
knn3 <- t(knn3) %*% knn3
knn4 <- t(knn4) %*% knn4

# iGraph Object
g1 <- graph_from_adjacency_matrix(knn1, mode="undirected")
g2 <- graph_from_adjacency_matrix(knn2, mode="undirected")
g3 <- graph_from_adjacency_matrix(knn3, mode="undirected")
g4 <- graph_from_adjacency_matrix(knn4, mode="undirected")

# Clustering
cluster1 <- cluster_louvain(g1)$membership
cluster2 <- cluster_louvain(g2)$membership
cluster3 <- cluster_louvain(g3)$membership
cluster4 <- cluster_louvain(g4)$membership

# Adjusted Rand Index
ari1 <- adjustedRandIndex(cluster1, cluster2)
ari2 <- adjustedRandIndex(cluster2, cluster3)
ari3 <- adjustedRandIndex(cluster3, cluster4)

# UMAP
umap1 <- umap(t(source_train))$layout
umap2 <- umap(t(v_s))$layout
umap3 <- umap(t(t_v_s))$layout
umap4 <- umap(t(rec_t_v_s))$layout

# Save
write.table(cluster1,
	outfile1, quote=FALSE, row.names=FALSE, col.names=FALSE)
write.table(cluster2,
	outfile2, quote=FALSE, row.names=FALSE, col.names=FALSE)
write.table(cluster3,
	outfile3, quote=FALSE, row.names=FALSE, col.names=FALSE)
write.table(cluster4,
	outfile4, quote=FALSE, row.names=FALSE, col.names=FALSE)
write.table(ari1,
	outfile5, quote=FALSE, row.names=FALSE, col.names=FALSE)
write.table(ari2,
	outfile6, quote=FALSE, row.names=FALSE, col.names=FALSE)
write.table(ari3,
	outfile7, quote=FALSE, row.names=FALSE, col.names=FALSE)
write.table(umap1,
	outfile8, quote=FALSE, row.names=FALSE, col.names=FALSE)
write.table(umap2,
	outfile9, quote=FALSE, row.names=FALSE, col.names=FALSE)
write.table(umap3,
	outfile10, quote=FALSE, row.names=FALSE, col.names=FALSE)
write.table(umap4,
	outfile11, quote=FALSE, row.names=FALSE, col.names=FALSE)
