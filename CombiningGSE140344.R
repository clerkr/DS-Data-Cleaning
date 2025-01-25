library(tidyverse)

dir_path = "/Users/jonathanroylance/CS_Projects/Lab/GSE140344/GSE140344_new.tsv"
file1 = "/Users/jonathanroylance/CS_Projects/Lab/GSE140344/GSE140344_Meth_UnMethSamples.csv"
tsv_file = read_tsv(file1)

# Add ID_REF to be the first column name
colnames(tsv_file) = c("ID_REF", colnames(tsv_file))


# The last column is a little weird (CTF29_Meth)
# It only contains methylation value in <chr>
# and it does not have unmethylation value
# So I'm assuming the white space divides the value into meth and unmeth
# Under this assumption, I'm gonna separate the column into two columns
separate(tsv_file, CTF29_Meth, into = c("CTF29_Meth",
      "CTF29_Unmeth"), sep = "\t",) %>%
  # Change all columns into <dbl> except for first column
  mutate(across(-1, as.numeric)) -> modified_data 
  

modified_data %>%
  pivot_longer(cols = -ID_REF, names_to = c("Sample", "Type"),
               names_pattern = "(.*)_(Meth|Unmeth)", values_to = "Values") %>%
  mutate(ID_REF = paste(Sample, ID_REF, sep = ".")) %>% # Prefix ID_REF with Sample
  select(ID_REF, Values, Type) %>%
  spread(Type, Values) %>%
  rename(Signal_A = Meth, Signal_B = Unmeth) %>%
  write_tsv(dir_path)
