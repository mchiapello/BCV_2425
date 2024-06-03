library(ovscout2)
library(tidyverse)
library(fs)
library(here)
# Create variables
ap <- readRDS(paste0(here(), '/data/partite.RDS'))
## Filter the right match
rm <- ap |>
     filter(data == '2024-05-30',
            team == 'U13F')
out <- as.character(rm$path)
match <- rm$match[[1]]
teams <- rm$teams[[1]]

################################################################################# Restart scouting
ov_scouter(dir_ls(paste0(here(), out), regexp = 'ovs$'),
           scouting_options = list(transition_sets = TRUE,
           attack_table = read_csv(paste0(here(), '/data/myAttacks.csv'))),
           app_styling = list(review_pane_width = 50),
           launch_browser = TRUE)

################################################################################
# Link Youtube video with scout
dvw <- dir_ls(paste0(here(), out), regexp = 'dvw$')
x <- dv_read(dvw)
dv_meta_video(x) <- ''
dv_write(x, dvw)

################################################################################
# Copy the dvw file into 'all' folder
file_copy(dir_ls(paste0(here(), out), regexp = 'dvw$'), here('scout', 'partite'), overwrite = TRUE)

################################################################################
# Remove video file
file_delete(dir_ls(paste0(here(), out), regexp = 'mp4$'))