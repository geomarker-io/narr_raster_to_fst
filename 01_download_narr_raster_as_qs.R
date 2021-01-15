library(dplyr)
library(tidyr)
library(purrr)
library(sf)
library(ncdf4)

# extract NARR raster cell values in long format as tbl for one year
save_NARR_values <- function(data.name, year) {

  ## download nc file
  ff <- paste0(
    "ftp://ftp.cdc.noaa.gov/Datasets/NARR/Dailies/monolevel/",
    data.name, ".",
    year, ".nc"
  )
  ff.short <- basename(ff)
  download.file(ff, destfile = ff.short, quiet = TRUE)
  on.exit(unlink(ff.short))

  d_narr <- raster::brick(ff.short)

  d_narr_tbl <-
    raster::extract(d_narr, 1:raster::ncell(d_narr)) %>%
    as_tibble(.name_repair = "minimal")

  d_narr_tbl_long <-
    d_narr_tbl %>%
    mutate(narr_cell = 1:raster::ncell(d_narr)) %>%
    pivot_longer(cols = -narr_cell, names_to = "date", values_to = data.name) %>%
    mutate(date = as.Date(date, format = "X%Y.%m.%d."))

  dir.create("narr", showWarnings = FALSE)
  qs::qsave(d_narr_tbl_long, glue::glue("./narr/narr_{data.name}_{year}.qs"), nthreads = parallel::detectCores())
}

## save_NARR_values('hpbl', '2000')

nms <- c("hpbl", "vis", "rhum.2m", "prate", "air.2m", "pres.sfc", "uwnd.10m", "vwnd.10m")
yrs <- as.character(2000:2020)

## save all years of each weather variable on disk
walk2(
  rep(nms, each = length(yrs)),
  rep(yrs, times = length(nms)),
  ~ save_NARR_values(data.name = .x, year = .y)
)
