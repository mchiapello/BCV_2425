# Read video file
video_file  <- dir_ls(out, regexp = "*mp4$")

# Prepate team players
## BVC Foglizzese
elat("data/elencoAtlete.csv", team = "BCV Caluso", out = out)
## Avversari
tibble(numero = NA, cognome = NA, nome = NA) |> 
  write_csv(paste0(out, "/", teams$team[teams$team != "BCV Caluso"], ".csv"))
elat(paste0(out, "/", teams$team[teams$team != "BCV Caluso"], ".csv"), 
     team = teams$team[teams$team != "BCV Caluso"], out = out)

# Ricordarsi di assegnare correttamente squadre in casa e fuori casa => 2 punti da cambiare
x <- dv_create(match = match, 
               teams = teams, 
               players_v = readRDS(paste0(out, "/BCV Caluso.RDS")), #<=====================================1
               players_h = readRDS(paste0(out, "/", teams$team[teams$team != "BCV Caluso"], ".RDS"))) #<===1
#2
# teams <- teams |>
#   arrange(home_away_team)
x$meta$teams <- teams

## Court ref
refx <- ovideo::ov_shiny_court_ref(video_file = video_file, t = 150)
saveRDS(refx, paste0(out, "/mrefx.RDS"))

## enter the team lineups for set 1
x <- dv_set_lineups(x, set_number = 1, 
                    lineups = list(c(4,5,13,7,10,3), 
                                   c(4,7,16,6,11,13)), 
                    setter_positions = c(1, 1))

# Subset the attacks
x$meta$attacks <- read_csv("data/myAttacks.csv")

# # Change shortcuts
# sc <- ov_default_shortcuts()
# sc$hide_popup <- c("k")

# Do the scouting
ov_scouter(x, video_file = video_file,
           court_ref = readRDS(paste0(out, "/mrefx.RDS")),
           scouting_options = list(transition_sets = TRUE,
                                   attack_table = read_csv("data/myAttacks.csv")),
           app_styling = list(review_pane_width = 50),
          # shortcuts = sc,
           launch_browser = TRUE)

# Restart scouting
ov_scouter(dir_ls(out, regexp = "ovs$"),
           scouting_options = list(transition_sets = TRUE,
                                   attack_table = read_csv("data/myAttacks.csv")),
           app_styling = list(review_pane_width = 50),
         #  shortcuts = sc,
           launch_browser = TRUE)

# Update court reference
# refx <- ovideo::ov_shiny_court_ref(video_file = video_file, t = 2800)
# outT <- "/Users/chiapell/personale/PALLAVOLO/U12F_Caluso_2324/partite/2024-03-09_Canavolley"

# Link Youtube video with scout
dvw <- dir_ls(out, regexp = "dvw$")
x <- dv_read(dvw)
dv_meta_video(x) <- "https://youtu.be/m3XFedJlFsw"
dv_write(x, dvw)
file_copy(dir_ls(out, regexp = "dvw$"), here("partite", "all"), overwrite = TRUE)

# Remove video file
file_delete(dir_ls(out, regexp = "mp4$"))















