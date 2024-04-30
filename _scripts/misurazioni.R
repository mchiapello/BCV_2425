library(tidyverse)

tmp <- tibble(date = lubridate::dmy("26/02/2024"),
       misure = c("Altezza", "Reach", "Muro", "Rincorsa"),
       "Chimienti-Martina" = c(143,184,205,210),
       "Fragonas-Matilde" = c(140,174,198,208),
       "Cireddu-Adele" = c(158,198,223,228),
       "Budau-Erika" = NA,
       "Panetto-Margherita" = NA,
       "Gerace-Valeria" = c(166,206,231,241),
       "Boni-Isabella" = c(164,207,232,243),
       "Beretta-Sharon" = c(157,200,232,242),
       "Gillone-Arianna" = c(170,219,241,246),
       "Mauro-Sharon" = NA,
       "La Monaca-Greta" = c(157, 201, 217, 221),
       "Torchia-Arianna" = c(162,205,225,231),
       "Celeste-Sara" = c(148,190,218,221),
       "De Luca-Aurora" = c(158,203,228,238)) |> 
  pivot_longer(cols = contains("-"),
               names_to = "atleta",
               values_to = "value") |> 
  pivot_wider(names_from = misure,
              values_from = value) |> 
  mutate(saltoFerma = Muro - Reach,
         saltoMovimento = Rincorsa - Reach) 

x <- read_csv(paste0(here::here(), "/data/misurazioni.csv"), show_col_types = FALSE)

x |> 
  bind_rows(tmp) |> 
  write_csv(paste0(here::here(), "/data/misurazioni.csv"))
