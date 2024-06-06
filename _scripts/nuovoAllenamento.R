# Define variavbles
### Folder
d <- "06/06/2024"
date <- lubridate::mdy(d)
team <- "U13U"
n <- 7
commento <- c("")
### File
categories <- c(team, "2024-2025", "Pre-season")
# # U13F
# convocate <- c("Per-Giu", "Del-Aur", "Gil-Ari", "Pan-Mar",
#                "Neg-Ire", "Tap-Ann", "Ber-Sil", "Cir-Ade",
#                "Bon-Isa", "Goy-Bea", "Ger-Val", "Tor-Ari")
# U13U
convocate <- c('Chi-Mar', 'Bud-Eri', 'Aud-Gin', 'Lam-Gre', 'Cel-Sar', 'Fra-Mat',
               'Urs-Ann', 'Agu-Bia', 'Mol-Gin', 'Fio-Mat', 'Cas-Giu', 'Col-Ann',
               'Ser-Sof')
assenti <- c('Ser-Sof', 'Chi-Mar', 'Bud-Eri', 'Urs-Ann', 'Agu-Bia', 'Mol-Gin',
             'Col-Ann')
vincitori <- c()
impegno <- 0.8
obiettivo <- 0.7
obiettivi <- "Amichevole - Fase gioco"
url <- NA

# Prepare the folder
dd <- lubridate::wday(date, label = TRUE)
if(dd == "Mon"){
  dd <- "M"
  palestra <- "Ubertini"
} else if (dd == "Tue") {
  dd <- "Tu"
  palestra <- "Scuole"
} else {
  dd <- "Th"
  palestra <- "Arè"
}
pat <- paste0("allenamenti/", date, "_",team, "_", dd, "_", n, ".qmd")
allen <- paste0(date, "_",team, "_", dd, "_", n, ".pdf")

# Prepare allenamento.qmd file
library(yaml)
library(tidyverse)
# Create a list with your YAML content
cat(paste0("---\n", 
           "date: ", date, "\n",
           "categories: ['", paste0(categories, collapse = "', '"), "']\n",
           "params:\n",
           "  squadra: '",team, "'\n",
           "  n: '", n, "'\n",
           "  allen: '", allen, "' \n",
           "  commento: '", commento, "'\n",
           "  palestra: '", palestra, "'\n",
           "  date: '", date, "'\n",
           "  allenamento: '", n, "'\n",
           "  convocate: ['", paste0(convocate, collapse = "', '"), "']\n",
           "  assenti: ['", paste0(assenti, collapse = "', '"), "']\n",
           "  vincitori: ['", paste0(vincitori, collapse = "', '"), "']\n",
           "  impegno: ", impegno, "\n",
           "  obiettivo: ", obiettivo, "\n",
           "  obiettivi: ", obiettivi, "\n",
           "  url: ", url, "\n",
           "execute:\n",
           "  echo: false\n",
           "  warning: false\n",
           "  message: false\n",
           "---\n\n",
           "## ", obiettivi, "\n",
           "{{< include ../_contents/_allenamento.qmd >}}"),
    file = pat)

# Prepare allenamento summary
if(fs::file_exists("data/allenamenti.RDS")){
  al_old <- readRDS("data/allenamenti.RDS")
  saveRDS(al_old, paste0(here::here(), "/data/allenamenti_old.RDS"))
  al <- tibble(squadra =team,
               data = date,
               N = n,
               tema = obiettivi,
               obiettivo = obiettivo,
               impegno = impegno)
  
  al_old_N <- al_old |> 
    filter(squadra %in%team,
           data %in% date) |> 
    nrow()
  
  if(al_old_N == 0){
    al_new <- al_old |> 
      bind_rows(al)
  } else {
    al_new <- al_old
  }
  saveRDS(al_new, "data/allenamenti.RDS")
} else {
  al <- tibble(squadra =team,
               data = date,
               N = n,
               tema = obiettivi,
               obiettivo = obiettivo,
               impegno = impegno)
  saveRDS(al, "data/allenamenti.RDS")
}


# Prepare presenze
players <- readRDS(paste0(here::here(), "/data/atlete2425.RDS"))

if(fs::file_exists("data/presenze.RDS")){
  presenze <- readRDS(paste0(here::here(), "/data/presenze.RDS"))
  saveRDS(presenze, paste0(here::here(), "/data/presenze_old.RDS"))
  
  out <- players |> 
    filter(ID %in% convocate) |> 
    mutate(data = date,
           squadra =team,
           presente = ifelse(ID %in% assenti, 0, 1)) |> 
    select(-nascita)
  
  nr <- presenze |> 
    filter(data %in% date,
           squadra %in% team) |> 
    nrow()
  
  if(nr == 0){
    df <- presenze |> 
      bind_rows(out)
  } else {
    df <- presenze
  }
  saveRDS(df, paste0(here::here(), "/data/presenze.RDS"))
} else {
  out <- players |> 
    filter(ID %in% convocate) |> 
    mutate(data = date,
           squadra =team,
           presente = ifelse(ID %in% assenti, 0, 1)) |> 
    select(-nascita)
  saveRDS(out, paste0(here::here(), "/data/presenze.RDS"))
}

################################################################################
# Create summary table
tt <- tibble(
  data = date,
  categories = paste0("'", paste0(categories, collapse = "', '"), "'"),
  squadra = team,
  n = n,
  allen = allen,
  commento = commento,
  palestra = palestra,
  allenamento = n,
  convocate = list(
    tibble(ID = convocate) |> left_join(players)
  ),
  assenti = list(
    tibble(ID = assenti)
  ),
  vincitori = list(
    tibble(ID = vincitori)
  ),
  impegno = impegno,
  obiettivo = obiettivo,
  obiettivi = obiettivi,
  url = url
)

if(fs::file_exists("data/summaryAllenamenti.RDS")){
  old <- readRDS(paste0(here::here(), "/data/summaryAllenamenti.RDS"))
  saveRDS(old, paste0(here::here(), "/data/summaryAllenamenti_old.RDS"))
  
  nr2 <- old |> 
    filter(data %in% tt$data,
           squadra %in% tt$squadra) |> 
    nrow()
  
  if(nr2 == 0){
    df <- old |> 
      bind_rows(tt)
  } else {
    df <- tt
  }
  saveRDS(df, paste0(here::here(), "/data/summaryAllenamenti.RDS"))
} else {
  saveRDS(tt, paste0(here::here(), "/data/summaryAllenamenti.RDS"))
}
