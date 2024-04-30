dvw <- dir_ls(out, regexp = "dvw$")
x <- dv_read(dvw)
out2 <- out

## extract the plays
px <- datavolley::plays(x)

px2 <- px %>% 
  filter(!is.na(player_id),
         team == "BCV Caluso") %>% 
  mutate(Nome = player_name,
         fondamentale = skill)

px3 <- px2 %>% 
  filter(!is.na(video_time)) %>% 
  group_by(Nome, fondamentale) %>% 
  nest() %>% 
  arrange(Nome, fondamentale)

## define columns to show in the table
extra_cols <- c("player_name", "evaluation", "set_number",
                "home_team_score", "visiting_team_score")

setwd(out)
map(px3 %>% filter(Nome != "unknown player") %>% 
      mutate(Nome = str_remove(Nome, " ")) %>% 
      pull(Nome) %>% 
      unique, fs::dir_create)
setwd(here::here())

px3 <-  px3 %>% 
  filter(Nome != "unknown player") %>%
  mutate(out = map(data, ovideo::ov_video_playlist, meta = x$meta,
                   extra_cols = extra_cols),
         outfile = paste0(out2, "/", str_remove(Nome, " "), 
                          "/", fondamentale, ".html"))

px4 <- px3 %>% 
  filter(fondamentale %in% c("Attack", "Reception", "Serve", "Set", "Dig"))

for(i in 1:nrow(px4)){
  ovideo::ov_playlist_to_html(px4$out[[i]], 
                              table_cols = extra_cols,
                              outfile = px4$outfile[i])
}


library(ovlytics)
px_au <- ov_augment_plays(px)
px_au |> pull(ts_pass_quality)

attack_eff(px)

plays(x) %>% dplyr::filter(skill == "Attack") %>% group_by(player_name) %>%
dplyr::summarize(N_attacks = n(), att_eff = attack_eff(evaluation))

plays(x) %>% dplyr::filter(skill == "Serve") %>% group_by(player_name) %>%
  dplyr::summarize(N_attacks = n(), att_eff = serve_eff(evaluation))

plays(x) %>% dplyr::filter(skill == "Reception") %>% group_by(player_name) %>%
  dplyr::summarize(N_attacks = n(), att_eff = reception_eff(evaluation)) |> 
  arrange(att_eff)


library(volleysim)
library(datavolley)
library(dplyr)

## calculate the rates we need to simulate
rates <- vs_estimate_rates(x, target_team = "each")
vs_simulate_match(rates)
