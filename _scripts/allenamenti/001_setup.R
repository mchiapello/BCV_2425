# Needed libraries
library(datavolley)
library(ovscout2)
library(tidyverse)
library(fs)
library(here)
setwd(here())
source("_scripts/999_functions.R")

###############################################################################
# Create match/allenamento
opp <- "BCV1"
us <- "BCV2"
date <- "2024-05-20"

pp <- ma(date = date, 
         opp = opp,
         type = "allenamento",
         time = "18:00:00",
         season = "2024-2025",
         league = "FIPAV",
         phase = "Pre",
         home_away = FALSE,
         day_number = 3,
         match_number = NA,
         set_won = c(3,0),
         home_away_team  = c("*", "a"),
         won_match = c(TRUE, FALSE),
         coach = c("Chiapello", ""),
         assistent = c("", ""))

# Create variables
out <- pp[[1]]
match <- pp[[2]]
teams <- pp[[3]]

