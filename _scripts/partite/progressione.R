library(tidyverse)
library(datavolley)
library(gt)
library(gtExtras)
library(patchwork)
library(volleyreport)
source(paste0(here::here(), "/scripts/999_utils.R"))
# Read data
file <- fs::dir_ls(paste0(here::here(), "/partite/2024-01-20_Vela"), 
                   regexp = "dvw$")
x <- dv_read(file)
noi <- "BCV Caluso"
loro <- teams(x)[teams(x) != noi]
home <- teams(x)[1]
away <- teams(x)[2]

y <- plays(x)

y2 <- y |> 
  filter(!skill %in% c("Timeout", "Technical timeout")) |> 
  filter(!grepl("set", code)) |> 
  group_by(point_id, set_number) |> 
  nest() |> 
  group_by(set_number) |> 
  nest()


## FUNCTION
pippo <- function(x){
  # Remove the not needed rows and cols
  out1 <- x |> 
    filter(!is.na(player_id)) |> 
    select(team, code, skill, evaluation, video_time, phase, 
           point_won_by, home_team_score, visiting_team_score,
           home_score_start_of_point, visiting_score_start_of_point) |> 
    mutate(code = str_remove(code, "~.*"),
           score = paste0(home_team_score, " : ", visiting_team_score))
  tt <- range(out1$video_time)[2] - range(out1$video_time)[1] 
  # rename(!!home := home_team_score,
  #        !!away := visiting_team_score)
  
  out2 <- tibble("Home" = NA,
                 "Point" = NA,
                 "Away" = NA)
  
  if(unique(out1$point_won_by) == home){
    out2 <- out2 |> 
      bind_rows(tibble(Home = paste0(out1$code, collapse = " - "),
                       Point = paste0(unique(out1$score), "<br>(", tt, "s)"),
                       Away = NA))
  } else {
    out2 <- out2 |>
      bind_rows(tibble(Home = NA,
                       Point = paste0(unique(out1$score), "<br>(", tt, "s)"),
                       Away = paste0(out1$code, collapse = " - ")))
  }
}

################################################################################
# SET 1
tmp <- y2$data[[1]]
tmp |> 
  mutate(test = map(data, pippo)) |> 
  unnest(test) |> 
  select(Home:Away) |> 
  filter(if_any(everything(), ~ !is.na(.))) |> 
  mutate(Home = ifelse(is.na(Home), "-", Home),
         Away = ifelse(is.na(Away), "-", Away)) |> 
  gt() |> 
  tab_style(style = cell_fill(color = "#4DD4DB"),
            locations = cells_body(columns = "Home", 
                                   rows = Home != "-")) |> 
  tab_style(style = cell_fill(color = "#DBB04D"),
            locations = cells_body(columns = "Away", 
                                   rows = Away != "-")) |> 
  # tab_options(table.width = px(650)) %>% 
  cols_width(
    Home ~ px(300),
    Point ~ px(80),
    Away ~ px(300)
  ) |> 
  fmt_markdown(columns = TRUE) |> 
  cols_align(
    align = "center",
    columns = Point) |> 
  tab_header(
    title = md("Set 1"))

################################################################################
# SET 2
tmp <- y2$data[[2]]
tmp |> 
  mutate(test = map(data, pippo)) |> 
  unnest(test) |> 
  select(Home:Away) |> 
  filter(if_any(everything(), ~ !is.na(.))) |> 
  mutate(Home = ifelse(is.na(Home), "-", Home),
         Away = ifelse(is.na(Away), "-", Away)) |> 
  gt() |> 
  tab_style(style = cell_fill(color = "#4DD4DB"),
            locations = cells_body(columns = "Home", 
                                   rows = Home != "-")) |> 
  tab_style(style = cell_fill(color = "#DBB04D"),
            locations = cells_body(columns = "Away", 
                                   rows = Away != "-")) |> 
  # tab_options(table.width = px(650)) %>% 
  cols_width(
    Home ~ px(300),
    Point ~ px(80),
    Away ~ px(300)
  ) |> 
  fmt_markdown(columns = TRUE) |> 
  cols_align(
    align = "center",
    columns = Point) |> 
  tab_header(
    title = md("Set 2"))

################################################################################
# SET 3
tmp <- y2$data[[3]]
tmp |> 
  mutate(test = map(data, pippo)) |> 
  unnest(test) |> 
  select(Home:Away) |> 
  filter(if_any(everything(), ~ !is.na(.))) |> 
  mutate(Home = ifelse(is.na(Home), "-", Home),
         Away = ifelse(is.na(Away), "-", Away)) |> 
  gt() |> 
  tab_style(style = cell_fill(color = "#4DD4DB"),
            locations = cells_body(columns = "Home", 
                                   rows = Home != "-")) |> 
  tab_style(style = cell_fill(color = "#DBB04D"),
            locations = cells_body(columns = "Away", 
                                   rows = Away != "-")) |> 
  # tab_options(table.width = px(650)) %>% 
  cols_width(
    Home ~ px(300),
    Point ~ px(80),
    Away ~ px(300)
  ) |> 
  fmt_markdown(columns = TRUE) |> 
  cols_align(
    align = "center",
    columns = Point) |> 
  tab_header(
    title = md("Set 3"))
