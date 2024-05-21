library(tidyverse)
library(ovva)

ovva_shiny(data_path = c(allenamenti = "scout/allenamenti/",
                         partite = "scout/partite/"))



library(shiny)
library(ovideo)
playlist <- readr::read_csv(fs::dir_ls("partite/2023-11-25_Vela/playlist/", regex = "csv"))

shinyApp(
  ui = fluidPage(
    ov_video_js(youtube = TRUE, version = 2),
    ov_video_player(id = "yt_player", type = "youtube",
                    version = 2, controller_var = "my_dv",
                    style = "height: 480px; background-color: black;",
                    controls = tagList(tags$input(id = "my_dv_slider", type = "range", min = 0.05, max = 1.5, value = 1, 
                                                  step = 0.1, title = "Playback rate", style = "width:80px; display:inline;"),
                                       tags$button("Go", onclick = ov_playlist_as_onclick(playlist, "yt_player", controller_var = "my_dv")))
    ),
    tags$span(id = "subtitle"), tags$span(id = "subtitleskill"), ## <<--- ADDED
    tags$script("$('#my_dv_slider').on('input', function(e) { my_dv.set_playback_rate(Number(this.value)) });"),
    tags$script("my_dv.video_onstart = function() {
                   var el=document.getElementById('subtitle'); if (el !== null) { el.textContent=my_dv.video_controller.queue[my_dv.video_controller.current].subtitle; };
                   el=document.getElementById('subtitleskill'); if (el !== null) { el.textContent=my_dv.video_controller.queue[my_dv.video_controller.current].subtitleskill; };
                 }")
  ),
  server = function(input, output) {},
)
