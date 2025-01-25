library(tidyverse)

dir = "/Users/jonathanroylance/CS_Projects/Lab/GSE57360/" # Path to .tsv signal intensities file
file = "GSE57360_signal_intensities.txt"

data = read_tsv(paste0(dir, file))

to_write = tibble(
  ID_REF = character(),
  Signal_A = numeric(),
  Signal_B = numeric(),
  Pval = numeric()
)

col_names = colnames(data)
print(colnames(data))
print(length(colnames(data)))

for (col in 1:(length(col_names[which(grepl("_meth", col_names))]))) {
  print(col)
  m = col_names[which(grepl("_meth", col_names))][col]
  um = col_names[which(grepl("_nometh", col_names))][col]
  p = col_names[which(grepl("_pval", col_names))][col]
  print(m)
  print(um)
  print(p)
  prefix = substring(m, 1, nchar(m)-nchar("_meth"))
  print(prefix)

  data_temp = data |>
    select(ID_REF, m, um, p) |>
    mutate(ID_REF = paste0(prefix, ".", ID_REF)) |>
    rename("Signal_A" = contains("_meth")) |>
    rename("Signal_B" = contains("_nometh")) |>
    rename("Pval" = contains("_pval"))
  to_write = full_join(to_write, data_temp)
}

write_tsv(to_write, paste0(dir, "GSE57360_new.tsv"))




