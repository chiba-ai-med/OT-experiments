library("otTensor")
library("rTensor")

# Function
.l1_error <- function(x, y){
    abs(x - y)
}

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
outfile1 <- args[3]
outfile2 <- args[4]
outfile3 <- args[5]
epsilon <- as.numeric(args[6])

# Loading
source <- as.matrix(read.csv(infile1, header=FALSE))
target <- as.matrix(read.csv(infile2, header=FALSE))

# Optimal Transport
source <- as.tensor(log10(source+1))
target <- as.tensor(log10(target+1))
out <- OTT(source, target, f=1:2,
	loss=.l1_error, epsilon=epsilon)
t_source <- t(out$Ts[[1]]) %*% source@data %*% out$Ts[[2]]

# Save
write.table(out$Ts[[1]], outfile1, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(out$Ts[[2]], outfile2, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(t_source, outfile3, row.names=FALSE, col.names=FALSE, quote=FALSE)
