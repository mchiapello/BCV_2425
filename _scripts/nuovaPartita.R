library(tidyverse)
library(here)
library(fs)

# Define variavbles
d <- "06/06/2024"
date <- lubridate::mdy(d)
team <- "U13F"
home <- "Basso Canavese Volley"
away <- "Samone"
type <- "partite"
time <- "18:00:00"
season <- "2024-2025"
league <- "Amichevole"
phase <- ""
home_away <- TRUE
day_number <- 2
match_number <- NA
set_won <- c(3,0)
coach_home <- "Chiapello"
coach_away <- ""
shirt_colour_home <- "white"
shirt_colour_away <- "yellow"
home_away_team <- c("a", "*")


#######################################################################
# DO NOT TOUCH AFTER THIS POINT
#######################################################################
output <- vector(mode = "list", length = 3L)

# OUTPATH
mat <- paste0("/scout/", type, "/", 
              date, "_", 
              str_replace_all(str_to_title(home), " ", ""), "_", team,
              "-vs-", 
              str_replace_all(str_to_title(away), " ", ""))

dir_create(paste0(here(), mat))
output[[1]] <- mat 
  
# MATCH
output[[2]] <- tibble(date = lubridate::ymd(date),
                      time = lubridate::hms(time),
                      season = season,
                      league = league,
                      phase = phase,
                      home_away = home_away,
                      day_number = day_number,
                      match_number = match_number,
                      text_encodong = 1,
                      regulation = "indoor rally point",
                      zones_or_cones = "Z")
# TEAM
output[[3]] <- tibble(team_id = c(str_to_upper(str_sub(str_replace(home, " ", ""),
                                                         start = 1L, end = 3L)), 
                                    str_to_upper(str_sub(str_replace(away, " ", ""),
                                                         start = 1L, end = 3L))),
                        team = c(home, away),
                        set_won = set_won,
                        coach = c(coach_home, coach_away),
                        assistent = NA,
                        shirt_colour = c(shirt_colour_home,
                                         shirt_colour_away),
                        X7 = NA,
                        home_away_team  = c("*", "a")) |> 
                mutate(won_match = case_when(set_won == 3 ~ TRUE,
                                             set_won != 3 ~ FALSE))


## Summary table
df <- tibble(data = date,
       home = home,
       away = away,
       type = type,
       team = team,
       vinto = output[[3]] |> filter(team_id == "BAS") |> pull(won_match),
       path = list(output[[1]]),
       match = list(output[[2]]),
       teams = list(output[[3]]))


if(fs::file_exists("data/partite.RDS")){
  old <- readRDS(paste0(here::here(), "/data/partite.RDS"))
  saveRDS(old, paste0(here::here(), "/data/partite_old.RDS"))
  
  nr2 <- old |> 
    filter(data %in% df$data,
           team %in% df$team) |> 
    nrow()
  
  if(nr2 == 0){
    df2 <- old |> 
      bind_rows(df)
  } else {
    df2 <- df
  }
  saveRDS(df2, paste0(here::here(), "/data/partite.RDS"))
} else {
  saveRDS(df, paste0(here::here(), "/data/partite.RDS"))
}
