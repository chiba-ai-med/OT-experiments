library("tagcloud")
library("viridis")
library("ggplot2")
library("igraph")
library("umap")
library("RANN")
library("mclust")
library("reticulate")

# Function
.myhist <- function(x){
	x <- as.matrix(x)
	if(nrow(x) > ncol(x)){
		x <- t(x)
	}
	nr <- nrow(x)
	layout(seq_len(nr))
	for(i in seq_len(nr)){
		hist(x[i, ], breaks=50, main="")
	}
}

.myimage <- function(x, log=TRUE){
	if(log){
		image(log10(t(x[nrow(x):1, ])+1))
	}else{
		image(t(x[nrow(x):1, ]))
	}
}

.mycolor <- function(z){
smoothPalette(z,
	palfunc=colorRampPalette(
		viridis(100), alpha=TRUE))
}

.mycolor2 <- function(z){
	factor(z, levels=sort(unique(z)))
}

# Flip y-axis
.plot_tissue_section <- function(x, y, z, cex=1){
	plot(x, -y, col=.mycolor(z), pch=16, cex=cex, xaxt="n", yaxt="n", xlab="", ylab="", axes=FALSE)
}

.plot_tissue_section2 <- function(x, y, z, cex=1){
	plot(x, -y, col=.mycolor2(z), pch=16, cex=cex, xaxt="n", yaxt="n", xlab="", ylab="", axes=FALSE)
	legend("topright", legend=sort(unique(z)),
		col=factor(sort(unique(z))), pch=16, cex=2)
}
