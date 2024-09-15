source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
infile3 <- args[3]
outfile <- args[4]

# Loading
res.svd <- read.csv(infile1, header=FALSE)
res.nmf <- read.csv(infile2, header=FALSE)
res.nmf_td <- read.csv(infile3, header=FALSE)

# Pre-processing
data <- data.frame(
	method=c(
		rep("SVD", length=nrow(res.svd)),
		rep("NMF", length=nrow(res.nmf)),
		rep("NMF (PyTorchDecomp)", length=nrow(res.nmf_td))),
	epsilon=rep(c('1','1E+9','1E+11','1E+13'), times=3),
	value=c(res.svd[,], res.nmf[,], res.nmf_td[,]))

# Plot
g <- ggplot(data, aes(x=epsilon, y=value, fill=method))
g <- g + geom_bar(stat="identity", position="dodge")
g <- g + ylim(c(0,1))
ggsave(outfile, g, dpi=200, width=12, height=3)
