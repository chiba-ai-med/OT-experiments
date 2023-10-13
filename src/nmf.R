library("otTensor")
library("nnTensor")
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
outfile1 <- args[4]
outfile2 <- args[5]
outfile3 <- args[6]
epsilon <- as.numeric(args[7])

# Loading
source_test <- as.matrix(read.csv(infile1, header=FALSE))
source_train <- as.matrix(read.csv(infile2, header=FALSE))
target_train <- as.matrix(read.csv(infile3, header=FALSE))

# NMF
res_nmf_source_train <- NMF(source_train, J=5)
res_nmf_target_train <- NMF(target_train, J=5)

# Transform
source_train_dist <- as.matrix(dist(t(res_nmf_source_train$V)))
target_train_dist <- as.matrix(dist(t(res_nmf_target_train$V)))

source_train_dist <- source_train_dist / max(source_train_dist)
target_train_dist <- target_train_dist / max(target_train_dist)

source_train_dist <- as.tensor(source_train_dist)
target_train_dist <- as.tensor(target_train_dist)

# Optimal Transport
out <- OTT(source_train_dist, target_train_dist, f=c(1,1),
	num.sample=1000,
	loss=.l2_error, epsilon=epsilon, num.iter=200, verbose=TRUE)

# Plan
P <- out$Ts[[1]] / rowSums(out$Ts[[1]])

# Transportation
t_source_test <- t(t(source_test) %*% res_nmf_source_train$U %*% P %*% t(res_nmf_target_train$U))
t_source_train <- t(res_nmf_source_train$V %*% P %*% t(res_nmf_target_train$U))

# Save
write.table(P, outfile1, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_test, outfile2, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_train, outfile3, row.names=FALSE, col.names=FALSE, quote=FALSE)
