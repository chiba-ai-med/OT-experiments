# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
outfile <- args[3]

# Loading
t_source_label <- as.matrix(read.table(infile1, header=FALSE))
target_celltype <- as.matrix(read.csv(infile2, header=TRUE))

# Binarization
t_source_label <- t(apply(t_source_label, 1, function(x){
    tmp <- rep(0, length=length(x))
    tmp[which(max(x) == x)[1]] <- 1
    tmp
}))

target_celltype <- t(apply(target_celltype, 1, function(x){
    tmp <- rep(0, length=length(x))
    tmp[which(max(x) == x)[1]] <- 1
    tmp
}))

# Accuracy
acr <- sum(t_source_label * target_celltype) / nrow(t_source_label)

# Save
write.table(acr, outfile, row.names=FALSE, col.names=FALSE, quote=FALSE)
