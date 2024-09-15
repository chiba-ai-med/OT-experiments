library("otTensor")
library("rTensor")

# Function
.l2_error <- function(x, y){
    (x - y)^2
}

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
epsilon <- as.numeric(args[9])

# Loading
source_test <- as.matrix(read.csv(infile1, header=FALSE))
source_train <- as.matrix(read.csv(infile2, header=FALSE))
target_train <- as.matrix(read.csv(infile3, header=FALSE))
source_celltype <- as.matrix(read.csv(infile4, header=TRUE))

# Transform
source_train_dist <- as.matrix(dist(source_train))
target_train_dist <- as.matrix(dist(target_train))
source_train_dist <- source_train_dist / max(source_train_dist)
target_train_dist <- target_train_dist / max(target_train_dist)
source_train_dist <- as.tensor(source_train_dist)
target_train_dist <- as.tensor(target_train_dist)

# Optimal Transport
out <- OTT(source_train_dist, target_train_dist, f=c(1,1),
	num.sample=1000,
	loss=.l2_error, epsilon=epsilon, num.iter=100, verbose=TRUE)

# Transportation
t_source_test <- t(out$Ts[[1]]) %*% source_test
t_source_train <- t(out$Ts[[1]]) %*% source_train
t_source_label <- t(out$Ts[[1]]) %*% source_celltype
sum_t_source_label <- rowSums(t_source_label)
t_source_label <- t_source_label / sum_t_source_label

# Save
write.table(out$Ts[[1]], outfile1, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_test, outfile2, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_train, outfile3, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_label, outfile4, row.names=FALSE, col.names=FALSE, quote=FALSE)
