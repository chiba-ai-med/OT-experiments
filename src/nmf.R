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
epsilon <- as.numeric(args[14])

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

# Log-Transformation
source_test <- log10(source_test + 1)
source_train <- log10(source_train + 1)
target_train <- log10(target_train + 1)

# NMF
res_nmf_source_train <- NMF(source_train, J=4, num.iter=100)
res_nmf_target_train <- NMF(target_train, J=9, num.iter=100)
rec_error <- cbind(res_nmf_source_train$RecError,
	res_nmf_target_train$RecError)

# Factor Matrices
u_s <- res_nmf_source_train$U
v_s <- t(res_nmf_source_train$V)
u_t <- res_nmf_target_train$U
v_t <- t(res_nmf_target_train$V)

# Normalization
norm_s1 <- colSums(u_s)
norm_s2 <- rowSums(v_s)
norm_s <- norm_s1 * norm_s2
norm_s <- norm_s / sum(norm_s)
u_s <- t(t(u_s) / norm_s1)
v_s <- v_s / norm_s2

norm_t1 <- colSums(u_t)
norm_t2 <- rowSums(v_t)
norm_t <- norm_t1 * norm_t2
norm_t <- norm_t / sum(norm_t)
u_t <- t(t(u_t) / norm_t1)
v_t <- v_t / norm_t2

# Transform
source_train_dist <- as.matrix(dist(v_s))
target_train_dist <- as.matrix(dist(v_t))

source_train_dist <- source_train_dist / max(source_train_dist)
target_train_dist <- target_train_dist / max(target_train_dist)

source_train_dist <- as.tensor(source_train_dist)
target_train_dist <- as.tensor(target_train_dist)

# Optimal Transport
out <- OTT(source_train_dist, target_train_dist, f=c(1,1),
	ps=list(norm_s),
	qs=list(norm_t),
	num.sample=1000,
	loss=.l2_error, epsilon=epsilon, num.iter=200, verbose=TRUE)

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
write.table(rec_error, outfile9, row.names=FALSE, col.names=FALSE, quote=FALSE)