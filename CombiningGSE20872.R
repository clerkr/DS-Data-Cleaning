

library(tidyverse)

dir_path = "" # The directory containing all .txt files
tsv_files <- list.files(dir_path, pattern = "\\.txt$", full.names = TRUE)

to_write = tibble(
  ID_REF = character(),
  Signal_A = numeric(),
  Signal_B = numeric(),
  Pval = numeric()
)

for (file in tsv_files) {
  data = read_tsv(file, skip = 8)
  column_titles = colnames(data)
  signal_a_column <- grep("\\.Signal_A$", column_titles, value = TRUE)
  prefix <- str_extract(signal_a_column, "^[^.]+")
  data = select(data, "ID_REF", contains("Signal_A"), contains("Signal_B"), contains("Detection Pval")) |>
    mutate(ID_REF = paste0(prefix, ".", ID_REF)) |>
    rename("Signal_A" = contains("Signal_A")) |>
    rename("Signal_B" = contains("Signal_B")) |>
    rename("Pval" = contains("Detection Pval"))
  to_write = full_join(to_write, data)
}

write_tsv(to_write, paste0(dir_path, "/new.tsv"))




