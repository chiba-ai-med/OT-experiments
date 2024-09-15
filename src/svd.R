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
infile4 <- args[4]
outfile1 <- args[5]
outfile2 <- args[6]
outfile3 <- args[7]
outfile4 <- args[8]
outfile5 <- args[9]
outfile6 <- args[10]
outfile7 <- args[11]
outfile8 <- args[12]
epsilon <- as.numeric(args[13])

# Loading
source_test <- as.matrix(read.csv(infile1, header=FALSE))
source_train <- as.matrix(read.csv(infile2, header=FALSE))
target_train <- as.matrix(read.csv(infile3, header=FALSE))
source_celltype <- as.matrix(read.csv(infile4, header=TRUE))
# source_celltype <- t(apply(source_celltype, 1, function(x){
# 	tmp <- rep(0, length=length(x))
# 	tmp[which(max(x) == x)[1]] <- 1
# 	tmp
# }))

# SVD
res_svd_source_train <- svd(log10(source_train + 1), nu=4, nv=4)
res_svd_target_train <- svd(log10(target_train + 1), nu=9, nv=9)

# Factor Matrices
u_s <- res_svd_source_train$u
v_s <- t(res_svd_source_train$v)
u_t <- res_svd_target_train$u
v_t <- t(res_svd_target_train$v)

# Normalization
norm_s <- rowSums(v_s)
v_s <- v_s / norm_s
u_s <- t(t(u_s) * norm_s)

norm_t <- rowSums(v_t)
v_t <- v_t / norm_t
u_t <- t(t(u_t) * norm_t)

# Transform
source_train_dist <- as.matrix(dist(v_s))
target_train_dist <- as.matrix(dist(v_t))

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
t_source_test <- t(t(source_test) %*% u_s %*% P %*% t(u_t))
t_source_train <- t(t(v_s) %*% P %*% t(u_t))
t_source_label <- u_t %*% t(P) %*% t(u_s) %*% source_celltype
sum_t_source_label <- rowSums(t_source_label)
t_source_label <- t_source_label / sum_t_source_label

# Save
write.table(P, outfile1, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_test, outfile2, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_train, outfile3, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_label, outfile4, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(u_s, outfile5, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(v_s, outfile6, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(u_t, outfile7, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(v_t, outfile8, row.names=FALSE, col.names=FALSE, quote=FALSE)
