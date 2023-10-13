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
outfile1 <- args[4]
outfile2 <- args[5]
outfile3 <- args[6]
epsilon <- as.numeric(args[7])

# Loading
source_test <- as.matrix(read.csv(infile1, header=FALSE))
source_train <- as.matrix(read.csv(infile2, header=FALSE))
target_train <- as.matrix(read.csv(infile3, header=FALSE))

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

# Save
write.table(out$Ts[[1]], outfile1, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_test, outfile2, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_train, outfile3, row.names=FALSE, col.names=FALSE, quote=FALSE)
