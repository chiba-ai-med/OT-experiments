source("src/Functions.R")

# Argument
args <- commandArgs(trailingOnly = TRUE)
infile1 <- args[1]
infile2 <- args[2]
outfile <- args[3]

# Loading
source <- read.csv(infile1, header=FALSE)
estimated <- unlist(read.table(infile2, header=FALSE))

# Plot
png(outfile, width=1300, height=900, bg="transparent")
.plot_tissue_section(source[,2], source[,3], estimated)
dev.off()
