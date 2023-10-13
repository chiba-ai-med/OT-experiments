library("otTensor")
library("rTensor")

# Function
.absl2_error <- function(x, y){
	x <- abs(x)
	y <- abs(y)
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

# SVD
res_svd_source_train <- svd(source_train, nu=5, nv=5)
res_svd_target_train <- svd(target_train, nu=5, nv=5)

# Transform
source_train_dist <- as.matrix(dist(t(res_svd_source_train$v)))
target_train_dist <- as.matrix(dist(t(res_svd_target_train$v)))

source_train_dist <- source_train_dist / max(source_train_dist)
target_train_dist <- target_train_dist / max(target_train_dist)

source_train_dist <- as.tensor(source_train_dist)
target_train_dist <- as.tensor(target_train_dist)

# Optimal Transport
out <- OTT(source_train_dist, target_train_dist, f=c(1,1),
	num.sample=1000,
	loss=.absl2_error, epsilon=epsilon, num.iter=200, verbose=TRUE)

# Plan
P <- out$Ts[[1]] / rowSums(out$Ts[[1]])

# Transportation
t_source_test <- t(t(source_test) %*% res_svd_source_train$u %*% P %*% t(res_svd_target_train$u))
t_source_train <- t(res_svd_source_train$v %*% P %*% t(res_svd_target_train$u))

# Save
write.table(P, outfile1, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_test, outfile2, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_train, outfile3, row.names=FALSE, col.names=FALSE, quote=FALSE)
