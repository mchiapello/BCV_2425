library(datavolley)
library(volleyreport)
x <- dv_read("partite/2023-11-11_GianFerr/BCV-GianFer.dvw")

## generate the report
rpt <- vr_match_summary(x, style = "ov1", format = "paged_pdf")
