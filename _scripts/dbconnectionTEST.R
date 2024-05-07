library(tidyverse)
library(gt)
library(dbplyr)

library(dplyr)
con <- DBI::dbConnect(RSQLite::SQLite(), dbname = "atlete")

tbl(con, "atlete")


library(DBI)
mydb <- dbConnect(RSQLite::SQLite(), "data/DB.sqlite")

x <- tbl(mydb, "atlete") |> 
  left_join(tbl(mydb, "squadre"))


assenti <- c("Goy-Bea", "Del-Aur")

id <- tbl(mydb, "presenze") |> 
  as_tibble()

pr <- tbl(mydb, "atlete") |> 
  mutate(date = "2024-06-10",
         presente = ifelse(ID %in% assenti, 1, 0)) |> 
  select(ID, date, presente)

pr <- as_tibble(pr)

if(any(id$date %in% unique(pr$date))){
  print("Presenze già aggiunte")
} else {
  print("NO")
}

copy_to(mydb, pr, "presenze", append = TRUE)

tbl(mydb, "presenze") |> print(n=Inf)
