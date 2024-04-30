library(tidyverse)

add <- function(x, N = 1){
  tmp <- x$lab
  x |> 
    bind_rows(tibble(x = c(3, 3, 2, 1, 1, 2),
                     y = c(1, 2, 2, 2, 1, 1),
                     lab = tmp[c(2, 3, 4, 5, 6, 1)], 
                     rot = "R2")) |> 
    bind_rows(tibble(x = c(3, 3, 2, 1, 1, 2),
                     y = c(1, 2, 2, 2, 1, 1),
                     lab = tmp[c(3, 4, 5, 6, 1, 2)], 
                     rot = "R3")) |> 
    bind_rows(tibble(x = c(3, 3, 2, 1, 1, 2),
                     y = c(1, 2, 2, 2, 1, 1),
                     lab = tmp[c(4, 5, 6, 1, 2, 3)], 
                     rot = "R4")) |> 
    bind_rows(tibble(x = c(3, 3, 2, 1, 1, 2),
                     y = c(1, 2, 2, 2, 1, 1),
                     lab = tmp[c(5, 6, 1, 2, 3, 4)], 
                     rot = "R5")) |> 
    bind_rows(tibble(x = c(3, 3, 2, 1, 1, 2),
                     y = c(1, 2, 2, 2, 1, 1),
                     lab = tmp[c(6, 1, 2, 3, 4, 5)], 
                     rot = "R6")) |> 
    mutate(set = paste0("set", N))
}

x1 <- tibble(x = c(3, 3, 2, 1, 1, 2),
       y = c(1, 2, 2, 2, 1, 1),
       lab = c(4,6,16,15,12,5), 
       rot = "R1") 
x2 <- tibble(x = c(3, 3, 2, 1, 1, 2),
             y = c(1, 2, 2, 2, 1, 1),
             lab = c(4,8,6,2,1,7), 
             rot = "R1") 
x3 <- tibble(x = c(3, 3, 2, 1, 1, 2),
             y = c(1, 2, 2, 2, 1, 1),
             lab = c(4,15,17,6,3,11), 
             rot = "R1") 

set1 <- add(x1, 1)
set2 <- add(x2, 2)
set3 <- add(x3, 3)
court_colour <- "white"
grid_colour <- "black"
p1 <- set1 |> 
  ggplot(aes(x, y, label = lab)) +
  annotate(geom = "rect", xmin = 0.5, xmax = 3.5, 
           ymin = 0.5, ymax = 2.5, 
           fill = court_colour, 
           colour = "black") +
  annotate(geom = "rect", xmin = 0.3, xmax = 3.7, 
                  ymin = 2.48, ymax = 2.6, 
                  fill = grid_colour) +
  annotate("segment", x = 1.5, xend = 1.5, y = .5, yend = 2.5,
           colour = grid_colour) +
  annotate("segment", x = 2.5, xend = 2.5, y = .5, yend = 2.5,
           colour = grid_colour) +
  annotate("segment", x = .5, xend = 3.5, y = 1.7, yend = 1.7,
           colour = grid_colour) +
  geom_text(size = 6) +
  theme_void() +
  labs(title = "SET 1") +
  facet_wrap(vars(rot)) 
p2 <- set2 |> 
  ggplot(aes(x, y, label = lab)) +
  annotate(geom = "rect", xmin = 0.5, xmax = 3.5, 
           ymin = 0.5, ymax = 2.5, 
           fill = court_colour, 
           colour = "black") +
  annotate(geom = "rect", xmin = 0.3, xmax = 3.7, 
           ymin = 2.48, ymax = 2.6, 
           fill = grid_colour) +
  annotate("segment", x = 1.5, xend = 1.5, y = .5, yend = 2.5,
           colour = grid_colour) +
  annotate("segment", x = 2.5, xend = 2.5, y = .5, yend = 2.5,
           colour = grid_colour) +
  annotate("segment", x = .5, xend = 3.5, y = 1.7, yend = 1.7,
           colour = grid_colour) +
  geom_text(size = 6) +
  theme_void() +
  labs(title = "SET 2") +
  facet_wrap(vars(rot)) 
p3 <- set3 |> 
  ggplot(aes(x, y, label = lab)) +
  annotate(geom = "rect", xmin = 0.5, xmax = 3.5, 
           ymin = 0.5, ymax = 2.5, 
           fill = court_colour, 
           colour = "black") +
  annotate(geom = "rect", xmin = 0.3, xmax = 3.7, 
           ymin = 2.48, ymax = 2.6, 
           fill = grid_colour) +
  annotate("segment", x = 1.5, xend = 1.5, y = .5, yend = 2.5,
           colour = grid_colour) +
  annotate("segment", x = 2.5, xend = 2.5, y = .5, yend = 2.5,
           colour = grid_colour) +
  annotate("segment", x = .5, xend = 3.5, y = 1.7, yend = 1.7,
           colour = grid_colour) +
  geom_text(size = 6) +
  theme_void() +
  labs(title = "SET 3") +
  facet_wrap(vars(rot)) 

# library(patchwork)
# p1 / p2 / p3


set1 |> 
  bind_rows(set2) |> 
  bind_rows(set3)|> 
  ggplot(aes(x, y, label = lab)) +
  annotate(geom = "rect", xmin = 0.5, xmax = 3.5, 
           ymin = 0.5, ymax = 2.5, 
           fill = court_colour, 
           colour = "black") +
  annotate(geom = "rect", xmin = 0.3, xmax = 3.7, 
           ymin = 2.48, ymax = 2.6, 
           fill = grid_colour) +
  annotate("segment", x = 1.5, xend = 1.5, y = .5, yend = 2.5,
           colour = grid_colour) +
  annotate("segment", x = 2.5, xend = 2.5, y = .5, yend = 2.5,
           colour = grid_colour) +
  annotate("segment", x = .5, xend = 3.5, y = 1.7, yend = 1.7,
           colour = grid_colour) +
  geom_text(size = 6) +
  theme_void() +
  facet_grid(cols = vars(rot),
             rows = vars(set),
             switch = "y") 
