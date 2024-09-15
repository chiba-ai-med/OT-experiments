# Argument
args <- commandArgs(trailingOnly = TRUE)
outfile1 <- args[1]
outfile2 <- args[2]
outfile3 <- args[3]
outfile4 <- args[4]
outfile5 <- args[5]
outfile6 <- args[6]
outfile7 <- args[7]
outfile8 <- args[8]
outfile9 <- args[9]
outfile10 <- args[10]

# Loading
source_train_data <- read.csv("data/demo/public_lipid(sma)/A1/msi_lipid_pos_exp.csv", header=TRUE)
# 分割
# source_train_data <- ???
# source_test_data <- ???

target_train_data <- read.csv("data/demo/public_lipid(sma)/A1/msi_trs_posA1_exp.csv", header=TRUE)
# 分割
# target_train_data <- ???
# target_test_data <- ???

source_metadata <- read.csv('data/demo/public_lipid(sma)/A1/msi_lipid_pos_celltype.csv')
target_metadata <- read.csv('data/demo/public_lipid(sma)/A1/msi_trs_posA1_celltype.csv')








# Merge
source_test_data <- merge(source_test_data, source_metadata, by=c("X", "Y"))
target_test_data <- merge(target_test_data, target_metadata, by=c("X", "Y"))

# Preprocess (Celltype Label)
source_celltype <- source_test_data[,
	c("Astrocytes", "Microglia", "Neurons", "Oligodendrocytes")]
target_celltype <- target_test_data[,
	c("Astrocytes", "Microglia", "Neurons", "Oligodendrocytes")]

# Coordinates
source_x_coordinate <- source_test_data$X
source_y_coordinate <- source_test_data$Y
target_x_coordinate <- target_test_data$X
target_y_coordinate <- target_test_data$Y
colnames(source_test_data) <- NULL
colnames(target_test_data) <- NULL
source_test_data <- source_test_data[, 4]
target_test_data <- target_test_data[, 4]

# Preprocess (Train data)
source_coordinate <- data.frame(X=source_x_coordinate, Y=source_y_coordinate)
source_train_data <- sapply(unique(source_train_data$Id), function(x){
	merge(source_train_data[which(source_train_data$Id == x), 2:4],
		source_coordinate, by=c("X", "Y"))$Intensity
})

target_coordinate <- data.frame(X=target_x_coordinate, Y=target_y_coordinate)
target_train_data <- sapply(unique(target_train_data$Id), function(x){
	merge(target_train_data[which(target_train_data$Id == x), 2:4],
		target_coordinate, by=c("X", "Y"))$Intensity
})

# Save
write.table(source_test_data, outfile1, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(target_test_data, outfile2, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(source_train_data, outfile3, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(target_train_data, outfile4, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(source_x_coordinate, outfile5, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(source_y_coordinate, outfile6, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(target_x_coordinate, outfile7, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(target_y_coordinate, outfile8, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(source_celltype, outfile9, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(target_celltype, outfile10, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
