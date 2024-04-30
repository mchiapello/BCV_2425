library(fs)
library(tidyverse)
library(datavolley)
library(gt)
library(gtExtras)
d <- dir_ls("partite/all/", regexp = "dvw")
lx <- list()
## read each file
for (fi in seq_along(d)) lx[[fi]] <- dv_read(d[fi], insert_technical_timeouts = FALSE)
## now extract the play-by-play component from each and bind them together
px <- list()
for (fi in seq_along(lx)) px[[fi]] <- plays(lx[[fi]])
px <- do.call(rbind, px)

px %>% 
  count(match_id)

team_select <- "BCV Caluso"
pp <- px %>% 
  left_join(px %>% 
              mutate(time = str_sub(as.character(time), start = 1L, end = 10L)) %>% 
              count(match_id, team, time) %>% 
              filter(team != team_select) %>% 
              select(match_id, SQ = team, DT= time)) %>% 
  group_by(SQ, DT) %>%
  dplyr::summarize(SerT = sum(skill == "Serve" & team %in% team_select, na.rm = TRUE),
                   SerP = sum(evaluation_code == "#" & skill == "Serve" & team %in% team_select, na.rm = TRUE),
                   SerE = sum(evaluation_code == "=" & skill == "Serve" & team %in% team_select, na.rm = TRUE),
                   AtkT = sum(skill == "Attack" & team %in% team_select, na.rm = TRUE),
                   AtkP = sum(evaluation_code == "#" & skill == "Attack" & team %in% team_select, na.rm = TRUE),
                   AtkE = sum(evaluation_code == "=" & skill == "Attack" & team %in% team_select, na.rm = TRUE),
                   BloT = sum(skill == "Block" & team %in% team_select, na.rm = TRUE),
                   BloP = sum(evaluation_code == "#" & skill == "Block" & team %in% team_select, na.rm = TRUE),
                   BloE = sum(evaluation_code == "#" & skill == "Block" & team %in% team_select, na.rm = TRUE),
                   Tentativi = sum(SerT, AtkT, BloT),
                   Punti = sum(SerP, AtkP, BloP),
                   Errori = sum(SerE, AtkE, BloE)) %>% 
  ungroup()

pp %>% 
  mutate(`SerP%` = round(SerP/SerT*100, 0),
         `SerE%` = round(SerE/SerT*100, 0),
         `AtkP%` = round(AtkP/AtkT*100, 0),
         `AtkE%` = round(AtkE/AtkT*100, 0)) %>% 
  select(SQ, DT,
         `SerP%`, `SerE%`,
         `AtkP%`, `AtkE%`) %>% 
  gt::gt()


tmp <- px |> 
  select(match_id, point_id, set_number, video_time, team_touch_id, home_team,
         home_team_score, visiting_team, visiting_team_score,
         team, player_number, skill, evaluation, phase, 
         point_won_by) |> 
  na.omit()

tmp2 <- tmp |> 
  group_by(match_id, set_number) |> 
  nest()

x <- tmp2$data[[1]]

rally <- function(x, home_team = team_select){
  y <- x |> 
    group_by(point_id) |> 
    slice_tail() |> 
    ungroup() |> 
    mutate(duration = lead(video_time) - video_time) 
  
  home <- y |> 
    filter(point_won_by == home_team) |> 
    mutate(actionH = paste(player_number, skill, evaluation,
                           sep = " ")) |> 
    select(point_id, point_won_by, actionH)
  
  away <- y |> 
    filter(point_won_by != home_team) |> 
    mutate(actionA = paste(evaluation,skill, player_number, 
                           sep = " ")) |> 
    select(point_id, point_won_by, actionA)
  
  oo <- home |> 
    bind_rows(away) |> 
    arrange(point_id) |> 
    left_join(y |> select(point_id, home_team_score,
                          visiting_team_score)) |> 
    mutate(action = coalesce(actionH, actionA)) |> 
    select(-actionA, -actionH) |> 
    pivot_wider(names_from = point_won_by, 
                values_from = action) |> 
    mutate(score = paste0(home_team_score, " - ", visiting_team_score)) |>
    select(-point_id, -home_team_score, -visiting_team_score) %>%
    replace(is.na(.), "")
  
  indHE <- oo |> 
    mutate(ind = row_number()) |> 
    filter(if_any(1, ~ grepl("Error", .))) |> 
    pull(ind)     
  indHP <- oo |> 
    mutate(ind = row_number()) |> 
    filter(if_any(1, ~ grepl("Winning|Ace", .))) |> 
    pull(ind)
  indAE <- oo |> 
    mutate(ind = row_number()) |> 
    filter(if_any(2, ~ grepl("Error", .))) |> 
    pull(ind)     
  indAP <- oo |> 
    mutate(ind = row_number()) |> 
    filter(if_any(2, ~ grepl("Winning|Ace", .))) |> 
    pull(ind)
  
  oo[, c(1, 3, 2)] |> 
    gt() |> 
    tab_style(
      style = cell_text(color = "red"),
      locations = cells_body(
        columns = c(`BCV Caluso`),
        rows = indHE
      )
    ) |> 
    tab_style(
      style = cell_text(color = "green"),
      locations = cells_body(
        columns = c(`BCV Caluso`),
        rows = indHP
      )
    ) |> 
    tab_style(
      style = cell_text(color = "red"),
      locations = cells_body(
        columns = c(GianFerr),
        rows = indAE
      )
    ) |> 
    tab_style(
      style = cell_text(color = "green"),
      locations = cells_body(
        columns = c(GianFerr),
        rows = indAP
      )
    )
  # tab_style(
  #     style = cell_text(color = "red"),
  #     locations = cells_body(
  #         columns = c({{home_team}}),
  #         rows = {{home_team}} == "5 Attack Error"
  #     )
  # )
}




head(gtcars, 8) %>%
  dplyr::select(model:trim, mpg_city = mpg_c, mpg_hwy = mpg_h) %>%  
  gt(rowname_col = "model") %>% 
  tab_style(
    style = cell_text(color = "red"),
    locations = cells_body(
      columns = c(trim),
      rows = trim == "Base Convertible"
    )
  )

head(mtcars[,1:5]) %>% 
  tibble::rownames_to_column("car") %>% 
  gt() %>% 
  gt_highlight_rows(
    rows = c(1,3,5), 
    fill = "lightgrey",
    bold_target_only = TRUE,
    target_col = car
  )


################################################################################
str(lx ,max.level = 2)

df <- tibble(date = NA,
             avversario = NA,
             vinto = NA,
             match_id = NA)



for(i in seq_along(lx)) df[i,"date"] <- lx[[i]]$meta$match$date
for(i in seq_along(lx)) df[i,"avversario"] <- lx[[i]]$meta$teams |> filter(team_id != "BCV") |> pull(team)
for(i in seq_along(lx)) df[i,"vinto"] <- lx[[i]]$meta$teams |> filter(team_id == "BCV") |> pull(won_match)
for(i in seq_along(lx)) df[i,"match_id"] <- lx[[i]]$plays$match_id |> unique()
for(i in seq_along(lx)) df[i,"match_id"] <- lx[[i]]$plays$match_id |> unique()

df |> 
  left_join(px) |> 
  count(date, avversario, match_id) |> 
  filter(n > 1)


################################################################################
## take just the serves from the play-by-play data
serve_rate <- px |> 
  left_join(px %>% 
              mutate(time = str_sub(as.character(time), start = 1L, end = 10L)) |> 
              count(match_id, team, time) %>% 
              filter(team != team_select) %>% 
              select(match_id, SQ = team, DT= time)) |> 
  group_by(SQ, DT) |> 
  filter(skill == "Serve")|> 
  group_by(team, end_zone) |> 
  dplyr::summarize(n_serve = n()) |> 
  mutate(rate = n_serve/sum(n_serve)) |> 
  drop_na() |> 
  ungroup()

## add x, y coordinates associated with the zones
serve_rate <- cbind(serve_rate, dv_xy(serve_rate$end_zone, end = "lower"))
## for team 2, these need to be on the top half of the diagram
tm2i <- serve_rate$team == "BCV Caluso"
serve_rate[tm2i, c("x", "y")] <- dv_flip_xy(serve_rate[tm2i, c("x", "y")])
serve_rate <- serve_rate %>%
  mutate(x2 = case_when(x == 1 ~ 3,
                        x == 2 ~ 2,
                        x == 3 ~1),
         y2 = case_when(y == 1 ~ 6,
                        y == 2 ~ 5,
                        y == 3 ~ 4,
                        y == 4 ~ 3,
                        y == 5 ~ 2,
                        y == 6~ 1))

range02 <- function(x) {(x - min(x, na.rm=TRUE)) / diff(range(x, na.rm=TRUE))}

serve_rate %>%
  mutate(rate = range02(rate)) %>%
  ggplot(aes(x, y, fill = rate)) +
  geom_tile() +
  ggcourt(labels = "") +
  scale_fill_gradient2(low = "white",
                       high = "black",
                       name = "Scala Intensità") +
  labs(title = "Battute",
       subtitle = "Zona di arrivo") +
  annotate(geom = "text", x = 2, y = 0, label = ifelse(teams(x)[1] == noi, "Noi", "Loro"), size = 15) +
  annotate(geom = "text", x = 2, y = 7, label = ifelse(teams(x)[2] == noi, "Noi", "Loro"), size = 15) +
  theme(plot.title = element_text(hjust = .5, size = 40),
        plot.subtitle = element_text(hjust = .5, size = 30))






df2 <- df |> 
  left_join(px) |> 
  group_by(date, avversario, vinto, match_id) |> 
  nest() |> 
  mutate(n = map_int(data, nrow)) |> 
  filter(n > 1) |> 
  select(-n)

x <- df2$data[[1]]


servizio <- function(x){
  x |> 
    filter(skill == "Serve") |> 
    count(team, evaluation, set_number) |> 
    pivot_wider(names_from = evaluation,
                values_from = n) |> 
    arrange(team, set_number) |> 
    rowwise() |> 
    mutate(Totale = sum(across(Ace:`Positive, opponent some attack`), na.rm = TRUE)) |> 
    mutate(Positive = sum(across(c(Ace, `OK, no first tempo possible`, `Positive, opponent some attack`, `Positive, no attack`)), na.rm = TRUE)) |> 
    mutate(Negative = sum(across(c(Error, `Negative, opponent free attack`)), na.rm = TRUE)) |> 
    mutate(`Pos%` = Positive / Totale * 100,
           `Neg%` = Negative / Totale * 100) |> 
    select(-starts_with("Positive"), -starts_with("Negative"),
           -starts_with("OK"), -Ace, - Error)
}

df2 |> 
  mutate(servizio = map(data, servizio)) |> 
  unnest(servizio)



x |> 
  select(set_number, home_team_score, visiting_team_score) |> 
  group_by(set_number) |> 
  filter(home_team_score == max(home_team_score),
         visiting_team_score == max(visiting_team_score)) |> 
  distinct()

################################################################################
# Player progress
ii <- px |> 
  mutate(time2 = lubridate::ymd(str_sub(as.character(time), 
                                        start = 1L, end = 10L))) |> 
  select(match_id, team, time = time2) |> 
  filter(team != "BCV Caluso") |> 
  distinct()

## Battuta
px |> 
  filter(team == "BCV Caluso") |>
  filter(skill == "Serve") |> 
  mutate(evaluation2 = case_when(evaluation %in% c("Negative, opponent free attack",
                                                   "OK, no first tempo possible") ~ "Negative",
                                 evaluation %in% c("Positive, no attack",
                                                   "Positive, opponent some attack") ~ "Positive",
                                 TRUE ~ evaluation),
         evac = case_when(evaluation2 == "Ace" ~ "#1a9850",
                          evaluation2 == "Error" ~ "#a50026",
                          evaluation2 == "Positive" ~ "#a6d96a",
                          evaluation2 == "Negative" ~ "#f46d43")) |> 
  count(match_id, player_name, skill, evaluation2, evac) |> 
  left_join(ii) |> 
  ggplot(aes(x = time, y = n, color = evac)) +
  geom_line() +
  geom_point(size = .3) +
  scale_color_identity("Legend", guide = "legend", label = c("Ace", "Error", "Positive", "Negative")) +
  facet_wrap(vars(player_name), scales = "free")




################################################################################
# Reception performance
noi <- "BCV Caluso"

s1 <- px %>% 
  mutate(time2 = lubridate::ymd(str_sub(time, 1L, 10L))) |> 
  group_by(match_id, time2) |> 
  nest()

x <- s1$data[[1]]

recep <- function(x){
  point <- x |> 
    filter(team == noi,
           point_won_by == noi,
           skill == "Reception") |> 
    count(team, skill)
  tmp <- x |> 
    filter(team == noi,
           skill == "Reception") |> 
    count(evaluation)
  tibble(Performance = c("Error rate", "Perfect-Positive pass", "Pass efficiency",
                         "Sideout rate"),
         Values = NA) |> 
    mutate(Values = case_when(Performance == "Error rate" ~ tmp |> 
                                filter(evaluation == "Error") |> 
                                pull(n) / sum(tmp$n),
                              Performance == "Perfect-Positive pass" ~ tmp |> 
                                filter(evaluation %in% c("OK, no first tempo possible",
                                                         "Perfect pass",
                                                         "Positive, attack")) |> 
                                pull(n) |> sum() / sum(tmp$n),
                              Performance == "Pass efficiency" ~ ((tmp |> 
                                filter(evaluation %in% c("OK, no first tempo possible",
                                                         "Perfect pass",
                                                         "Positive, attack")) |> 
                                pull(n) |> sum()) - (tmp |> 
                                                       filter(evaluation %in% c("Error")) |> 
                                                       pull(n) |> sum())) / sum(tmp$n),
                              Performance == "Sideout rate" ~ point$n / sum(tmp$n)))
}

library(ggpmisc)

s1 |> 
  mutate(Reception = map(data, recep)) |> 
  unnest(Reception) |> 
  ggplot(aes(x = time2, y = Values)) +
  geom_point() +
  geom_line() +
  facet_wrap(vars(Performance)) +
  geom_smooth(method = lm) +
  scale_x_date(date_minor_breaks = "1 week", date_labels = "%Y %b %d", date_breaks = "1 week") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 0, vjust = .5)) +
  labs(x = "",
       y = "Rates")

s1 |> 
  mutate(Reception = map(data, recep)) |> 
  unnest(Reception) |> 
  ggplot(aes(x = time2, y = Values)) +
  stat_poly_line() +
  stat_poly_eq(use_label("eq")) +
  geom_point() +
  geom_line() +
  facet_wrap(vars(Performance)) +
  scale_x_date(date_minor_breaks = "1 week", date_labels = "%Y %b %d", date_breaks = "1 week") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 0, vjust = .5)) +
  labs(x = "",
       y = "Rates")


################################################################################
scale_vector <- function(vec) {
  min_val <- min(vec)
  max_val <- max(vec) * 1.1
  
  # Handle cases where all numbers are negative
  if (max_val <= 0) {
    scaled_vec <- -1 * (vec - min_val) / (max_val - min_val) * 10
  } else {
    scaled_vec <- (vec - min_val) / (max_val - min_val) * 10
  }
  
  return(scaled_vec)
}


serve_score <- px |> 
  filter(team == "BCV Caluso") |>
  filter(skill == "Serve") |> 
  mutate(evaluation2 = case_when(evaluation %in% c("Negative, opponent free attack",
                                                   "OK, no first tempo possible") ~ "Negative",
                                 evaluation %in% c("Positive, no attack",
                                                   "Positive, opponent some attack") ~ "Positive",
                                 TRUE ~ evaluation)) |> 
  count(player_name, evaluation2) |> 
  mutate(n = ifelse(evaluation2 %in% c("Error", "Negative"), n * -1, n * 1)) |> 
  group_by(player_name) |> 
  summarise(Serve_score = sum(n)) |> 
  mutate(Serve_score = scale_vector(Serve_score)) |> 
  arrange(desc(Serve_score))
  



