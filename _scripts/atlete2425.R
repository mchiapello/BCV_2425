library(tidyverse)

x <- read_csv("data/atlete.csv")

df <- x |> 
  mutate(nascita = lubridate::ymd(nascita)) |> 
  mutate(ID = paste0(str_to_title(str_sub(str_replace(cognome, " ", ""), 1L, 3L)), 
                     "-", str_to_title(str_sub(nome, 1L, 3L))), .before = cognome) 

saveRDS(df, "data/atlete2425.RDS")
write_csv(df, "data/atlete2425.csv")
