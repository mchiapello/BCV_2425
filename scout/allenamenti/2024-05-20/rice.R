# Load library
library(datavolley)
library(fs)
library(here)
library(tidyverse)
library(volleyreport)
library(gt)

# read data
file <- dir_ls(paste0(here(), "/scout/allenamenti/2024-05-20"), regexp = "dvw")
x <- read_dv(file)

px <- plays(x)

# Reception score
vr_reception(px, team = "BCV1", by = "player")


ric <- px |> 
  dplyr::filter(skill == "Reception") |> 
  mutate(evaluation2 = case_when(evaluation %in% c("Negative, limited attack",
                                                   "Poor, no attack") ~ "Negative",
                                 evaluation %in% c("OK, no first tempo possible",
                                                   "Positive, attack") ~ "Positive",
                                 TRUE ~ evaluation)) |> 
  count(player_name, evaluation2) |> 
  group_by(player_name) |> 
  mutate(tot = sum(n),
         Percent = n / tot * 100)

ric |> 
  select(player_name:tot) |> 
  pivot_wider(names_from = evaluation2,
              values_from = n) |> 
  filter(player_name != "unknown player") |> 
  mutate(`Prf%` = round(((`Perfect pass`) - Error) / tot * 100, 1), 
         `Pos%` = round(((`Perfect pass` + Positive) - Error) / tot * 100, 1)) |> 
  ungroup() |> 
  gt() |> 
  tab_style(
    style = cell_text(color = "red"),
    locations = cells_body(
      columns = "Prf%",
      rows = `Prf%` < 0 
    )
  ) |> 
  tab_style(
    style = cell_text(color = "blue"),
    locations = cells_body(
      columns = "Pos%",
      rows = `Pos%` > 60 
    )
  )




xrecep <- px |> 
  filter(skill == "Reception")

se <- px |> 
  filter(skill == "Set", lag(skill) == "Reception") 


px |> 
  group_by(point_id) |> 
  filter(skill %in% c("Reception", "Set")) |> 
  count(point_id) |> filter(n < 2)



ggplot(xrecep, aes(start_coordinate_x, start_coordinate_y,
                    xend = end_coordinate_x, yend = end_coordinate_y, colour = evaluation)) +
  geom_segment(arrow = arrow(length = unit(2, "mm"), type = "closed", angle = 20)) +
  scale_colour_manual(values = c(Ace = "limegreen", Error = "firebrick", Other = "dodgerblue"),
                      name = "Evaluation") +
  ggcourt()


px %>% 
  mutate(set_coordinate_x = case_when(skill == "Reception" ~ lead(start_coordinate_x)),
              set_coordinate_y = case_when(skill == "Reception" ~ lead(start_coordinate_y))) %>%
  mutate(evaluation2 = case_when(skill == "Reception" & evaluation %in% c("Negative, limited attack",
                                                   "Poor, no attack") ~ "Negative",
                                 skill == "Reception" & evaluation %in% c("OK, no first tempo possible",
                                                   "Positive, attack") ~ "Positive",
                                 skill == "Reception" & TRUE ~ evaluation)) |> 
  filter(player_id == "Per-Giu") |> 
  ggplot(aes(end_coordinate_x, end_coordinate_y, xend = set_coordinate_x, yend = set_coordinate_y, colour = evaluation2)) +
  geom_segment(arrow = arrow(length = unit(2, "mm"), type = "closed", angle = 20)) + ggcourt() +
  facet_wrap(vars(end_zone))

px %>% 
  mutate(set_coordinate_x = case_when(skill == "Reception" ~ lead(start_coordinate_x)),
         set_coordinate_y = case_when(skill == "Reception" ~ lead(start_coordinate_y))) %>%
  mutate(evaluation2 = case_when(skill == "Reception" & evaluation %in% c("Negative, limited attack",
                                                                          "Poor, no attack") ~ "Negative",
                                 skill == "Reception" & evaluation %in% c("OK, no first tempo possible",
                                                                          "Positive, attack") ~ "Positive",
                                 skill == "Reception" & TRUE ~ evaluation)) |> 
  filter(player_id == "Cir-Ade") |> 
  ggplot(aes(set_coordinate_x, set_coordinate_y, 
             colour = evaluation2)) +
  geom_point() + ggcourt() +
  facet_wrap(vars(end_zone))
