source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
outfile1 <- args[3]
outfile2 <- args[4]

# 
source <- read.csv(infile1, header=FALSE)
target <- read.csv(infile2, header=FALSE)

# Plot
png(outfile1, width=1300, height=900, bg="transparent")
.plot_tissue_section(source[,2], source[,3], source[,4])
dev.off()

# Plot
png(outfile2, width=1300, height=900, bg="transparent")
.plot_tissue_section(target[,2], target[,3], target[,4])
dev.off()
