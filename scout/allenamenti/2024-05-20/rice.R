# Load library
library(datavolley)
library(fs)
library(here)
library(tidyverse)
library(volleyreport)
library(gt)

# read data
file <- dir_ls(paste0(here(), "/scout/allenamenti/2024-05-20"), regexp = "dvw")
x <- read_dv(file)

px <- plays(x)

# Reception score
vr_reception(px, team = "BCV1", by = "player")


ric <- px |> 
  dplyr::filter(skill == "Reception") |> 
  mutate(evaluation2 = case_when(evaluation %in% c("Negative, limited attack",
                                                   "Poor, no attack") ~ "Negative",
                                 evaluation %in% c("OK, no first tempo possible",
                                                   "Positive, attack") ~ "Positive",
                                 TRUE ~ evaluation)) |> 
  count(player_name, evaluation2) |> 
  group_by(player_name) |> 
  mutate(tot = sum(n),
         Percent = n / tot * 100)

ric |> 
  select(player_name:tot) |> 
  pivot_wider(names_from = evaluation2,
              values_from = n) |> 
  filter(player_name != "unknown player") |> 
  mutate(`Prf%` = round(((`Perfect pass`) - Error) / tot * 100, 1), 
         `Pos%` = round(((`Perfect pass` + Positive) - Error) / tot * 100, 1)) |> 
  ungroup() |> 
  gt() |> 
  tab_style(
    style = cell_text(color = "red"),
    locations = cells_body(
      columns = "Prf%",
      rows = `Prf%` < 0 
    )
  ) |> 
  tab_style(
    style = cell_text(color = "blue"),
    locations = cells_body(
      columns = "Pos%",
      rows = `Pos%` > 60 
    )
  )

