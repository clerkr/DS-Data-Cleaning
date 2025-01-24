library(tidyverse)

file1 = "C:/Users/sophi/Documents/Piccolo's Lab/GSE140344/GSE140344_Meth_UnMethSamples.csv"
tsv_file = read_tsv(file1)

# Add ID_REF to be the first column name
colnames(tsv_file) = c("ID_REF", colnames(tsv_file))

# Extract column names
column_names = colnames(tsv_file)
methylated_colnames = column_names[which(grepl("Meth", column_names))]
unmethylated_colnames = column_names[which(grepl("Unmeth", column_names))]

# Extract first 

#tsv_file |>
#  head(n = 10) |>
#  print()

