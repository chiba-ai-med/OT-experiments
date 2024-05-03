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
x_axis <- unlist(read.csv(infile1, header=FALSE))
y_axis <- unlist(read.csv(infile2, header=FALSE))
plan <- as.matrix(read.table(infile3, header=FALSE))
test_transported <- unlist(read.table(infile4, header=FALSE))
train_transported <- read.table(infile5, header=FALSE)

# Plot
tmp <- paste0(gsub("finish", "", outfile), "test.png")
png(tmp, width=1000, height=450, bg="transparent")
.plot_tissue_section(x_axis, y_axis, test_transported, cex=2)
dev.off()

# Plot
for(i in seq_len(ncol(train_transported))){
	tmp <- paste0(gsub("finish", "", outfile), "train_", i, ".png")
	png(tmp, width=1000, height=450, bg="transparent")
	.plot_tissue_section(x_axis, y_axis, train_transported[,i], cex=2)
	dev.off()
}

# Plot
tmp <- paste0(gsub("finish", "", outfile), "plan.png")
png(tmp, width=1500, height=1500)
image(log10(plan+1))
dev.off()

file.create(outfile)