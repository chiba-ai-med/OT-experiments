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
outfile4 <- args[7]
epsilon <- as.numeric(args[7])

# Loading
print("Loading")
source_test <- as.matrix(read.csv(infile1, header=FALSE))
source_train <- as.matrix(read.csv(infile2, header=FALSE))
target_train <- as.matrix(read.csv(infile3, header=FALSE))

# Transform
print("Transform")
source_test <- log10(source_test + 1)
source_train <- log10(source_train + 1)
target_train <- log10(target_train + 1)

source_train <- as.tensor(source_train)
target_train <- as.tensor(target_train)

# Optimal Transport
print("OTT")
out <- OTT(source_train, target_train, f=c(1,2),
	loss=.l2_error, epsilon=epsilon)

# Transportation
print("Transportation")
t_source_test <- t(out$Ts[[1]]) %*% source_test %*% out$Ts[[2]]
t_source_train <- t(out$Ts[[1]]) %*% source_train@data %*% out$Ts[[2]]

# Save
print("Save")
write.table(out$Ts[[1]], outfile1, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(out$Ts[[2]], outfile2, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(t_source_test, outfile3, row.names=FALSE, col.names=FALSE, quote=FALSE)
write.table(t_source_train, outfile4, row.names=FALSE, col.names=FALSE, quote=FALSE)
