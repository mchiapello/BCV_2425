library(ovscout2)
library(tidyverse)
library(fs)
library(here)

# Create variables
ap <- readRDS("data/partite.RDS")
## Filter the right match
rm <- ap |> 
  filter(data == "2024-05-30", # <===== TO CHANGE
         team == "U13U")       # <===== TO CHANGE
out <- as.character(rm$path)
match <- rm$match[[1]]
teams <- rm$teams[[1]]

################################################################################
# Restart scouting
ov_scouter(dir_ls(paste0(here(), out), regexp = "ovs$"),
           scouting_options = list(transition_sets = TRUE,
                                   attack_table = read_csv("data/myAttacks.csv")),
           app_styling = list(review_pane_width = 50),
           #  shortcuts = sc,
           launch_browser = TRUE)
