library(tidyverse)
library(gt)
library(gtExtras)

df <- read_csv("tmp/U12_COPPA.csv") |> 
  mutate(data = str_replace(data, "Sun", "dom"),
         data = str_replace(data, "Sat", "sab"))
# Nostre partite
noi <- "Basso Canavese VolleyY Gialla"
df  |> 
  filter(`Home Team` == noi | `Away Team` == noi)  |> 
  # slice(7:10) |>
  gt()  |> 
  gt::tab_header(title = gt::md("**Calendario**"))  |> 
  gtExtras::gt_theme_538() 

# Creare eventi per google calendar
df |> 
  filter(`Home Team` == noi | `Away Team` == noi)|> 
  mutate(data = str_remove_all(data, "sab\\/|dom\\/|ven\\/")) |> 
  mutate("Subject" = "Partita U12F",
         `Start Date` = data,
         `End Date` = data,
         `Start Time` = str_remove(ora, "ore "),
         `End Time` = paste0(as.integer(str_sub(`Start Time`, start = 1L, end = 2L)) + 2,
                             str_sub(`Start Time`, start = 3L, end = 5L)),
         "Description" = paste0(`Home Team`, " - ", `Away Team`),
         "Location" = luogo)  |>  
  select(Subject, `Start Date`, `End Date`, `Start Time`, `End Time`, 
         Description, Location) %>% 
  write_csv("tmp/calendarioNOSTRO2023_v2.csv")
