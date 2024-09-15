source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
infile3 <- args[3]
infile4 <- args[4]
infile5 <- args[5]
infile6 <- args[6]
infile7 <- args[7]
outfile <- args[8]

# Loading
x_axis_source <- unlist(read.csv(infile1, header=FALSE))
y_axis_source <- unlist(read.csv(infile2, header=FALSE))
x_axis_target <- unlist(read.csv(infile3, header=FALSE))
y_axis_target <- unlist(read.csv(infile4, header=FALSE))
test_transported <- unlist(read.table(infile5, header=FALSE))
train_transported <- as.matrix(read.table(infile6, header=FALSE))
t_source_label <- as.matrix(read.table(infile7, header=FALSE))

# Pre-processing
test_transported[which(is.nan(test_transported))] <- 0
train_transported[which(is.nan(train_transported))] <- 0
# 場合わけがそのうち必要そう
colnames(t_source_label) <- c("Astrocytes", "Microglia", "Neurons", "Oligodendrocytes")
t_source_label <- apply(t_source_label, 1, function(x){
	colnames(t_source_label)[which(x == max(x))[1]]
})

# Plot Transported Slice (Test)
tmp <- paste0(gsub("finish", "", outfile), "test.png")
png(tmp, width=2000, height=2000, bg="transparent")
.plot_tissue_section(x_axis_target, y_axis_target, test_transported)
dev.off()

# Plot Transported Slice (Train)
for(i in seq_len(ncol(train_transported))){
	tmp <- paste0(gsub("finish", "", outfile), "train_", i, ".png")
	png(tmp, width=2000, height=2000, bg="transparent")
	.plot_tissue_section(x_axis_target, y_axis_target, train_transported[,i])
	dev.off()
}

# Plot Transported Label (Train)
tmp <- paste0(gsub("finish", "", outfile), "celltype.png")
png(tmp, width=2000, height=2000, bg="transparent")
.plot_tissue_section2(x_axis_target, y_axis_target, t_source_label)
dev.off()

# Empty File
file.create(outfile)
