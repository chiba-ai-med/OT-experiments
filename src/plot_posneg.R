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
infile8 <- args[8]
outfile1 <- args[9]
outfile2 <- args[10]
outfile3 <- args[11]
outfile4 <- args[12]

# Loading
pos_test_data <- unlist(read.csv(infile1, header=FALSE))
neg_test_data <- unlist(read.csv(infile2, header=FALSE))
pos_train_data <- read.csv(infile3, header=FALSE)
neg_train_data <- read.csv(infile4, header=FALSE)
pos_x_coordinate <- unlist(read.csv(infile5, header=FALSE))
pos_y_coordinate <- unlist(read.csv(infile6, header=FALSE))
neg_x_coordinate <- unlist(read.csv(infile7, header=FALSE))
neg_y_coordinate <- unlist(read.csv(infile8, header=FALSE))

# Plot
outdir_pos <- gsub("source_test_data_finish", "", outfile1)
outdir_neg <- gsub("target_test_data_finish", "", outfile2)

# Plot (1)
outfile_pos_test <- paste0(outdir_pos, "pos_test_data.png")
png(outfile_pos_test, width=1000, height=450, bg="transparent")
.plot_tissue_section(pos_x_coordinate, pos_y_coordinate,
	pos_test_data, cex=2)
dev.off()

# Plot (Many)
for(i in seq_len(ncol(pos_train_data))){
	tmp <- paste0(outdir_pos, "pos_train_data_", i, ".png")
	png(tmp, width=1000, height=450, bg="transparent")
	.plot_tissue_section(pos_x_coordinate, pos_y_coordinate,
		pos_train_data[,i], cex=2)
	dev.off()
}

# Plot (1)
outfile_neg_test <- paste0(outdir_neg, "neg_test_data.png")
png(outfile_neg_test, width=1000, height=450, bg="transparent")
.plot_tissue_section(neg_x_coordinate, neg_y_coordinate,
	neg_test_data, cex=2)
dev.off()

# Plot (Many)
for(i in seq_len(ncol(neg_train_data))){
	tmp <- paste0(outdir_neg, "neg_train_data_", i, ".png")
	png(tmp, width=1000, height=450, bg="transparent")
	.plot_tissue_section(neg_x_coordinate, neg_y_coordinate,
		neg_train_data[,i], cex=2)
	dev.off()	
}

# Save
file.create(outfile1)
file.create(outfile2)
file.create(outfile3)
file.create(outfile4)
