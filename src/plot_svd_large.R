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
infile11 <- args[11]
infile12 <- args[12]
outfile <- args[13]

# Loading
x_axis_source <- unlist(read.csv(infile1, header=FALSE))
y_axis_source <- unlist(read.csv(infile2, header=FALSE))
x_axis_target <- unlist(read.csv(infile3, header=FALSE))
y_axis_target <- unlist(read.csv(infile4, header=FALSE))
plan <- as.matrix(read.table(infile5, header=FALSE))
test_transported <- unlist(read.table(infile6, header=FALSE))
train_transported <- as.matrix(read.table(infile7, header=FALSE))
t_source_label <- as.matrix(read.table(infile8, header=FALSE))
u_s <- as.matrix(read.table(infile9, header=FALSE))
v_s <- as.matrix(read.table(infile10, header=FALSE))
u_t <- as.matrix(read.table(infile11, header=FALSE))
v_t <- as.matrix(read.table(infile12, header=FALSE))

# Pre-processing
plan[which(is.nan(plan))] <- 0
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

# Plot Transport Plan
tmp <- paste0(gsub("finish", "", outfile), "plan.png")
png(tmp, width=2000, height=2000)
.myimage(plan)
dev.off()

if(ncol(u_s) <= 10){
	# Plot Factor Matrices (Heatmap)
	tmp <- paste0(gsub("finish", "", outfile), "u_s_heatmap.png")
	png(tmp, width=300, height=2000)
	.myimage(u_s)
	dev.off()
	tmp <- paste0(gsub("finish", "", outfile), "v_s_heatmap.png")
	png(tmp, width=2000, height=400)
	.myimage(v_s)
	dev.off()
	tmp <- paste0(gsub("finish", "", outfile), "u_t_heatmap.png")
	png(tmp, width=400, height=2000)
	.myimage(u_t)
	dev.off()
	tmp <- paste0(gsub("finish", "", outfile), "v_t_heatmap.png")
	png(tmp, width=2000, height=400)
	.myimage(v_t)
	dev.off()

	# Plot Factor Matrices (Histgram)
	tmp <- paste0(gsub("finish", "", outfile), "u_s_histgram.png")
	png(tmp, width=1500, height=1500)
	.myhist(u_s)
	dev.off()
	tmp <- paste0(gsub("finish", "", outfile), "v_s_histgram.png")
	png(tmp, width=1500, height=1500)
	.myhist(v_s)
	dev.off()
	tmp <- paste0(gsub("finish", "", outfile), "u_t_histgram.png")
	png(tmp, width=1500, height=1500)
	.myhist(u_t)
	dev.off()
	tmp <- paste0(gsub("finish", "", outfile), "v_t_histgram.png")
	png(tmp, width=1500, height=1500)
	.myhist(v_t)
	dev.off()
}

# Plot Rank-1 Matrices (Source)
for(i in seq_len(ncol(u_s))){
	tmp <- paste0(gsub("finish", "", outfile), "source_rank1_", i, ".png")
	png(tmp, width=2000, height=2000, bg="transparent")
	.plot_tissue_section(x_axis_source, y_axis_source,
		as.vector(outer(u_s[, i], v_s[i, ])), cex=2)
	dev.off()
}

# Plot Rank-1 Matrices (Target)
for(i in seq_len(ncol(u_t))){
	tmp <- paste0(gsub("finish", "", outfile), "target_rank1_", i, ".png")
	png(tmp, width=2000, height=2000, bg="transparent")
	.plot_tissue_section(x_axis_target, y_axis_target,
		as.vector(outer(u_t[, i], v_t[i, ])), cex=2)
	dev.off()
}

# Plot Reconstruction Matrices
t_v_s <- t(plan) %*% v_s
for(i in seq_len(ncol(u_t))){
	tmp <- paste0(gsub("finish", "", outfile), "rec_", i, ".png")
	png(tmp, width=2000, height=2000, bg="transparent")
	.plot_tissue_section(x_axis_target, y_axis_target,
		as.vector(outer(u_t[,i], t_v_s[i,])))
	dev.off()
}

file.create(outfile)