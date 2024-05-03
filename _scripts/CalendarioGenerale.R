library(calendR)
library(tidyverse)
library(ggtext)

# Vector of NA of the same length of the number of days of the year
events <- rep(NA, 303)

# Set the corresponding events
events[seq(2,303, by = 7)] <- "All"
events[seq(3,303, by = 7)] <- "U13F"
events[seq(5,303, by = 7)] <- "U13F - U13U"
events[seq(6,303, by = 7)] <- "U12"
events[c(62, 114:118, 182:185, 229:234, 237, 243:245, 275)] <- "Festa"
events[c(128, 129)] <- "Torneo BF"
events[c(seq(42,112, by = 7),
         seq(133, 255, by = 7))] <- "Partite"

calendR(from = "2024-09-01",
        to = "2025-06-30",
        start = "M",
        special.days = events,
        special.col = c('#8dd3c7','#fb8072','#80b1d3','#ffffb3',
                        '#bebada','#fdb462','#b3de69'),
        legend.pos = "bottom",
        title = "BCV (Under 13/Under 12) 2024/2025",
        title.size = 30)








calendR(year = 2024,
        month = 9,
        start = "M") +
  annotate("text", x = 0, y = 5.3, label = "**U13F**") +
  annotate("rect", xmin = .5, xmax = 1.5,
           ymin = 2.16, ymax = 2.5, alpha = .3, fill = "#fb8072", color = "black") +
  annotate("rect", xmin = .5, xmax = 1.5,
           ymin = 1.84, ymax = 2.16, alpha = .3, fill = "#b3de69", color = "black") +
  annotate("rect", xmin = .5, xmax = 1.5,
           ymin = 1.5, ymax = 1.84, alpha = .3, fill = "#fb8072", color = "black") 


u13f <- tibble(
              label = c(rep("18-20 <span style='color:MediumSlateBlue'>**U13F**</span> (Ubertini)", 5), 
                        rep("18-20 <span style='color:MediumSlateBlue'>**U13F**</span> (Arè)", 4),
                        rep("18-20 <span style='color:MediumSlateBlue'>**U13F**</span> (Poli)", 2)),
              x = c(rep(0.1, 5), rep(3.1, 5), rep(1.1, 2))[-10],
              y = c(rep(seq(5.3, 1.3, by = -1), 2), 5.3, 3.3)[-10],
              hjust = .5,
              vjust = .5,
              fill = "red"
)
u13u <- tibble(
              label = c(rep("18-20 <span style='color:Magenta'>**U13U**</span> (Arè)", 5),
                        rep("18-20 <span style='color:Magenta'>**U13U**</span> (Arè)", 4),
                        rep("18-20 <span style='color:Magenta'>**U13U**</span> (Poli)", 2)),
              x = c(rep(0.1, 5), rep(3.1, 5), rep(1.1, 2))[-10],
              y = c(rep(seq(5, 1, by = -1), 2), 4, 2)[-10],
              hjust = .5,
              vjust = .5,
              fill = "red"
)
u12u <- tibble(
              label = c(rep("18-20 <span style='color:IndianRed'>**U12U**</span> (Arè)", 5),
                        rep("18-20 <span style='color:IndianRed'>**U12U**</span> (Poli)", 4)),
              x = c(rep(0.1, 5), rep(4.1, 5))[-10],
              y = rep(seq(4.7, .7, by = -1), 2)[-10],
              hjust = .5,
              vjust = .5,
              fill = "red"
)


sampleImage = png::readPNG("../images/BCV.png") %>%
      grid::rasterGrob(interpolate = TRUE)

calendR(year = 2024,
        month = 9,
        start = "M",
        title = "BCV - Under 12/13 Femminile",
        subtitle = "Settembre 2024") +
geom_richtext(data = u13f, 
              aes(x, y, label = label)) +
geom_richtext(data = u13u, 
              aes(x, y, label = label)) +
geom_richtext(data = u12u, 
              aes(x, y, label = label))  +coord_cartesian(clip = 'off') +
annotation_custom(sampleImage, x = 1.3, y = 7.2, ymax = 7.7, xmax = 2)

ggsave(filename = "deleteme.pdf", units = "mm", width = 297, height = 210, scale = 1.45)
