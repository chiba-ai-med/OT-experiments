library("tagcloud")
library("viridis")

.mycolor <- function(z){
smoothPalette(z,
	palfunc=colorRampPalette(
		viridis(100), alpha=TRUE))
}

# Flip y-axis
.plot_tissue_section <- function(x, y, z, cex=1){
	plot(x, -y, col=.mycolor(z), pch=16, cex=cex, xaxt="n", yaxt="n", xlab="", ylab="", axes=FALSE)
}

