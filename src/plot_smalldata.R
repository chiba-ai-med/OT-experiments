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
infile9 <- args[9]
infile10 <- args[10]
outfile1 <- args[11]
outfile2 <- args[12]
outfile3 <- args[13]
outfile4 <- args[14]

# Loading
source_test_data <- unlist(read.csv(infile1, header=FALSE))
target_test_data <- unlist(read.csv(infile2, header=FALSE))
source_train_data <- as.matrix(read.csv(infile3, header=FALSE))
target_train_data <- as.matrix(read.csv(infile4, header=FALSE))
source_x_coordinate <- unlist(read.csv(infile5, header=FALSE))
source_y_coordinate <- unlist(read.csv(infile6, header=FALSE))
target_x_coordinate <- unlist(read.csv(infile7, header=FALSE))
target_y_coordinate <- unlist(read.csv(infile8, header=FALSE))
source_celltype <- read.csv(infile9, header=TRUE)
target_celltype <- read.csv(infile10, header=TRUE)

# Pre-processing
source_test_data <- log10(source_test_data + 1)
target_test_data <- log10(target_test_data + 1)
source_train_data <- log10(source_train_data + 1)
target_train_data <- log10(target_train_data + 1)
source_celltype <- apply(source_celltype, 1, function(x){
	colnames(source_celltype)[which(x == max(x))[1]]
})
target_celltype <- apply(target_celltype, 1, function(x){
	colnames(target_celltype)[which(x == max(x))[1]]
})

# Plot
outdir_pos <- gsub("source_test_data_finish", "", outfile1)
outdir_neg <- gsub("target_test_data_finish", "", outfile2)

# Plot (Source/Test)
outfile_source_test <- paste0(outdir_pos, "source_test_data.png")
png(outfile_source_test, width=1000, height=450, bg="transparent")
.plot_tissue_section(source_x_coordinate, source_y_coordinate,
	source_test_data)
dev.off()

# Plot (Source/Train)
for(i in seq_len(ncol(source_train_data))){
	tmp <- paste0(outdir_pos, "source_train_data_", i, ".png")
	png(tmp, width=1000, height=450, bg="transparent")
	.plot_tissue_section(source_x_coordinate, source_y_coordinate,
		source_train_data[,i])
	dev.off()
}

# Plot (Target/Test)
outfile_target_test <- paste0(outdir_neg, "target_test_data.png")
png(outfile_target_test, width=1000, height=450, bg="transparent")
.plot_tissue_section(target_x_coordinate, target_y_coordinate,
	target_test_data)
dev.off()

# Plot (Target/Train)
for(i in seq_len(ncol(target_train_data))){
	tmp <- paste0(outdir_neg, "target_train_data_", i, ".png")
	png(tmp, width=1000, height=450, bg="transparent")
	.plot_tissue_section(target_x_coordinate, target_y_coordinate,
		target_train_data[,i])
	dev.off()
}

# Plot (Celltype/Target)
outfile_source_celltype <- paste0(outdir_neg, "source_celltype.png")
png(outfile_source_celltype, width=1000, height=450, bg="transparent")
.plot_tissue_section2(source_x_coordinate, source_y_coordinate,
	source_celltype)
dev.off()

# Plot (Celltype/Train)
outfile_target_celltype <- paste0(outdir_neg, "target_celltype.png")
png(outfile_target_celltype, width=1000, height=450, bg="transparent")
.plot_tissue_section2(target_x_coordinate, target_y_coordinate,
	target_celltype)
dev.off()

# Save
file.create(outfile1)
file.create(outfile2)
file.create(outfile3)
file.create(outfile4)
