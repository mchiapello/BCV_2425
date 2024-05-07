# Define variavbles
### Folder
d <- "05/13/2024"
date <- lubridate::mdy(d)
team <- "U13F"
n <- 1
### File
categories <- c(team, "2024-2025", "Pre-season")
convocate <- c("Per-Giu", "Del-Aur", "Gil-Ari", "Pan-Mar",
               "Neg-Ire", "Tap-Ann", "Ber-Sil", "Cir-Ade",
               "Bon-Isa", "Goy-Bea", "Ger-Val", "Tor-Ari")
assenti <- c()
vincitori <- c()
impegno <- 0.8
obiettivo <- 0.8
obiettivi <- "Clessidra - Attacco"
url <- NA

# Prepare the folder
dd <- lubridate::wday(date, label = TRUE)
if(dd == "Mon"){
  dd <- "M"
  palestra <- "Ubertini"
} else {
  dd <- "G"
  palestra <- "Arè"
}
pat <- paste0("allenamenti/", date, "_", team, "_", dd, "_", n, ".qmd")


# Prepare file
library(yaml)
library(tidyverse)
# Create a list with your YAML content
cat(paste0("---\n", 
           "date: ", d, "\n",
           "categories: ['", paste0(categories, collapse = "', '"), "']\n",
           "params:\n",
           "  palestra: '", palestra, "'\n",
           "  date: '", str_replace(as.character(date), 
                                    "(\\d\\d\\d\\d)-(\\d\\d)-(\\d\\d)", 
                                    "\\3/\\2/\\1"), "'\n",
           "  allenamento: '", n, "'\n",
           "  convocate: ['", paste0(convocate, collapse = "', '"), "']\n",
           "  assenti: ['", paste0(assenti, collapse = "', '"), "']\n",
           "  vincitori: ['", paste0(vincitori, collapse = "', '"), "']\n",
           "  impegno: ", impegno, "\n",
           "  obiettivo: ", obiettivo, "\n",
           "  url: ", url, "\n",
           "execute:\n",
           "  echo: false\n",
           "  warning: false\n",
           "  message: false\n",
           "---\n\n",
           "## Obiettivi: ", obiettivi, "\n",
           "{{< include ../../_contents/_allenamento.qmd >}}"),
    file = pat)
