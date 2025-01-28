library(tidyverse)

dir = "/Users/jonathanroylance/CS_Projects/Lab/GSE140344/" # Path to .tsv signal intensities file
file = "GSE140344_Meth_UnMethSamples.csv"

data = read_tsv(paste0(dir, file))

to_write = tibble(
  ID_REF = character(),
  Signal_A = numeric(),
  Signal_B = numeric()
)

m_title = "_Meth"
um_title = "_Unmeth"

col_names = colnames(data)
m_cols = col_names[which(grepl(m_title, col_names))]
um_cols = col_names[which(grepl(um_title, col_names))]
print(colnames(data))
print(length(colnames(data)))

for (col in 1:(length(m_cols))) {
  print(col)
  m = m_cols[col]
  um = um_cols[col]
  print(m)
  print(um)
  prefix = substring(m, 1, nchar(m)-nchar(m_title))
  print(prefix)

  data_temp = data |>
    select(ID_REF, m, um) |>
    mutate(ID_REF = paste0(prefix, ".", ID_REF)) |>
    rename("Signal_A" = contains(m_title)) |>
    rename("Signal_B" = contains(um_title))
  to_write = full_join(to_write, data_temp)
}

write_tsv(to_write, paste0(dir, "GSE140344_new.tsv"))




