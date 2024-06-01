# Load libraries
library(datavolley)
library(ovscout2)
library(tidyverse)
library(fs)
library(here)
setwd(here())
source("_scripts/999_functions.R")

################################################################################
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
# Read video file
video_file  <- dir_ls(paste0(here(), out), regexp = "*mp4$")

################################################################################
# Prepate team players
# u13u <- c('Chi-Mar', 'Bud-Eri', 'Aud-Gin', 'Lam-Gre', 'Cel-Sar', 
#           'Fra-Mat', 'Urs-Ann', 'Agu-Bia', 'Mol-Gin', 'Fio-Mat', 
#           'Cas-Giu', 'Col-Ann', 'Ser-Sof')
# u13f <- c('Per-Giu', 'Del-Aur', 'Gil-Ari', 'Pan-Mar', 'Neg-Ire', 'Tap-Ann', 
#           'Ber-Sil', 'Cir-Ade', 'Bon-Isa', 'Goy-Bea', 'Ger-Val', 'Tor-Ari')

## BVC 
bcv <- readRDS("data/atlete2425.RDS") |> 
  filter(ID %in% c('Chi-Mar', 'Lam-Gre', 'Cel-Sar', 'Fio-Mat',
                   'Fra-Mat', 'Urs-Ann', 'Agu-Bia', 
                   'Cas-Giu', 'Col-Ann')) |> 
  left_join(readRDS("data/numeriMaglia.RDS")) |> 
  select(number, firstname = nome, lastname = cognome)

## Avversari
#' If from FIPAV website: 
#' Copy the teams in vim and use the following regex sub: %s/\n\(\w\+\s\w\+\)/ \1/g

#' if from UISP
#' Write the team from the game sheet
# aa <- tribble(~number, ~firstname, ~lastname,
#              1,"Pippo","Topolino") 
# Create random opponent team
set.seed(1)
aa <- tibble(number = 1:6,
             firstname = replicate(6, str_to_title(paste0(sample(letters, 5), collapse = ""))),
             lastname = replicate(6, str_to_title(paste0(sample(letters, 5), collapse = ""))))

if(teams$team_id[1] == "BAS"){
  home <- as.data.frame(bcv)
  visiting <- as.data.frame(aa)
} else {
  home <- as.data.frame(aa)
  visiting <- as.data.frame(bcv)
}

# Ricordarsi di assegnare correttamente squadre in casa e fuori casa => 2 punti da cambiare
x <- dv_create(match = match, 
               teams = teams, 
               players_h = home,
               players_v = visiting) 

################################################################################
## Court ref
refx <- ovideo::ov_shiny_court_ref(video_file = video_file, t = 100)
saveRDS(refx, paste0(here(), out, "/mrefx.RDS"))

## enter the team lineups for set 1
x <- dv_set_lineups(x, set_number = 1, 
                    lineups = list(c(24,18,17,13,16,23), 
                                   c(1:6)), 
                    setter_positions = c(1, 1))

################################################################################
# Subset the attacks
x$meta$attacks <- read_csv("data/myAttacks.csv")

# # Change shortcuts
# sc <- ov_default_shortcuts()
# sc$hide_popup <- c("k")

################################################################################
# Do the scouting
ov_scouter(x, video_file = video_file,
           court_ref = readRDS(paste0(here(), out, "/mrefx.RDS")),
           scouting_options = list(transition_sets = TRUE,
                                   attack_table = read_csv("data/myAttacks.csv")),
           app_styling = list(review_pane_width = 50),
          # shortcuts = sc,
           launch_browser = TRUE)

################################################################################
########################## TO DO ###################################
#### Add a way to create a scout.R file into the out folder, so I can restart the scaut from the ovl file
################################################################################

################################################################################
# Restart scouting
ov_scouter(dir_ls(paste0(here(), out), regexp = "ovs$"),
           scouting_options = list(transition_sets = TRUE,
                                   attack_table = read_csv("data/myAttacks.csv")),
           app_styling = list(review_pane_width = 50),
         #  shortcuts = sc,
           launch_browser = TRUE)

################################################################################
# Update court reference
# refx <- ovideo::ov_shiny_court_ref(video_file = video_file, t = 2800)
# outT <- "/Users/chiapell/personale/PALLAVOLO/U12F_Caluso_2324/partite/2024-03-09_Canavolley"

################################################################################
# Link Youtube video with scout
dvw <- dir_ls(out, regexp = "dvw$")
x <- dv_read(dvw)
dv_meta_video(x) <- "https://youtu.be/m3XFedJlFsw"
dv_write(x, dvw)

################################################################################
# Copy the dvw file into 'all' folder
file_copy(dir_ls(out, regexp = "dvw$"), here("partite", "all"), overwrite = TRUE)

################################################################################
# Remove video file
file_delete(dir_ls(out, regexp = "mp4$"))















