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

# Loading
pos_test_data <- read.table("data/posneg/DCTB/DCTB_pos/20220809_testPG_Brain_DCTB_30um_Pos_int.txt", header=TRUE)
pos_train_data <- read.table("data/posneg/DCTB/DCTB_pos/20220809_train_Brain_DCTB_30um_Pos_int.txt", header=TRUE)
neg_test_data <- read.csv("data/posneg/DCTB/DCTB_neg/20220810_testPG_Brain_DCTB_afterPos_30um_Neg_int.txt",
	row.names=1, header=TRUE)
neg_train_data <- read.csv("data/posneg/DCTB/DCTB_neg/20220810_train_Brain_DCTB_afterPos_30um_Neg_int.txt",
	row.names=1, header=TRUE)

# Coordinates
pos_x_coordinate <- pos_test_data$X
pos_y_coordinate <- pos_test_data$Y
neg_x_coordinate <- neg_test_data$X
neg_y_coordinate <- neg_test_data$Y
colnames(pos_test_data) <- NULL
colnames(neg_test_data) <- NULL
pos_test_data <- pos_test_data[,4]
neg_test_data <- neg_test_data[,4]

# Preprocess (Train data)
pos_train_data <- sapply(unique(pos_train_data$Id), function(x){
	pos_train_data[which(pos_train_data$Id == x), 4]
})

neg_train_data <- sapply(unique(neg_train_data$Id), function(x){
	neg_train_data[which(neg_train_data$Id == x), 4]
})

# Save
write.table(pos_test_data, outfile1, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(neg_test_data, outfile2, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(pos_train_data, outfile3, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(neg_train_data, outfile4, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(pos_x_coordinate, outfile5, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(pos_y_coordinate, outfile6, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(neg_x_coordinate, outfile7, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
write.table(neg_y_coordinate, outfile8, row.names=FALSE, col.names=FALSE, quote=FALSE, sep=",")
