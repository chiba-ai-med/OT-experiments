# Argument
args <- commandArgs(trailingOnly = TRUE)
outfile1 <- args[1]
outfile2 <- args[2]
outfile3 <- args[3]
outfile4 <- args[4]

# Loading
data <- read.table("data/lipid/20220809_Brain_DHB_30um_Pos_int.txt", header=TRUE)

# Preprocess (Vector data)
index_source <- Reduce(intersect,
	list(which(data$Id == 13),
		which(data$X > 1650),
		which(data$X < 1700),
		which(data$Y > 320),
		which(data$Y < 370)))
index_target <- Reduce(intersect,
	list(which(data$Id == 14),
		which(data$X > 1650),
		which(data$X < 1700),
		which(data$Y > 320),
		which(data$Y < 370)))

vec_source <- data[index_source, ]
vec_target <- data[index_target, ]

colnames(vec_source) <- NULL
colnames(vec_target) <- NULL

# Preprocess (Matrix data)
mat_source <- as.matrix(vec_source[,4])
mat_target <- as.matrix(vec_target[,4])
n <- max(vec_source[,2]) - min(vec_source[,2]) + 1
m <- max(vec_target[,2]) - min(vec_target[,2]) + 1
dim(mat_source) <- c(n, nrow(vec_source)/n)
dim(mat_target) <- c(n, nrow(vec_target)/m)
colnames(mat_source) <- NULL
colnames(mat_target) <- NULL

# Save
write.table(vec_source, outfile1, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(vec_target, outfile2, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(mat_source, outfile3, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(mat_target, outfile4, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")

