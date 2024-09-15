source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
infile3 <- args[3]
infile4 <- args[4]
infile5 <- args[5]
outfile <- args[6]

# Loading
res.gw <- read.csv(infile1, header=FALSE)
res.ott_gw <- read.csv(infile2, header=FALSE)
res.svd <- read.csv(infile3, header=FALSE)
res.nmf <- read.csv(infile4, header=FALSE)
res.nmf_td <- read.csv(infile5, header=FALSE)

# Pre-processing
data <- data.frame(
	method=c(
		rep("GW", length=nrow(res.gw)),
		rep("GW (OTT)", length=nrow(res.ott_gw)),
		rep("SVD", length=nrow(res.svd)),
		rep("NMF", length=nrow(res.nmf)),
		rep("NMF (PyTorchDecomp)", length=nrow(res.nmf_td))),
	epsilon=c(
        c('1E+8','1E+9','1E+10','1E+11','1E+12','1E+13','1E+14'),
        c('1E+9', '1E+11', '1E+13')
    rep(c('0','1E+9','1E+11','1E+13'), times=3)),
	value=c(res.gw[,], res.ott_gw[,], res.svd[,], res.nmf[,], res.nmf_td[,]))

# Plot
g <- ggplot(data, aes(x=epsilon, y=value, fill=method))
g <- g + geom_bar(stat="identity", position="dodge")
g <- g + ylim(c(0,1))
ggsave(outfile, g, dpi=200, width=12, height=3)
