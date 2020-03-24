#### example point application
library(sf)
library(dplyr)
library(tidyr)

source("./get_narr_data.R")

raw_data <- readr::read_csv("test/my_address_file_geocoded.csv")
raw_data$.row <- seq_len(nrow(raw_data))

d <-
  raw_data %>%
  select(.row, lat, lon) %>%
  na.omit() %>%
  nest(.rows = c(.row)) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# reproject points into NARR projection for overlay
d <- d %>%
  sf::st_transform(crs = raster::crs(r_narr_empty))

# get NARR cell number for each point
d <- d %>%
  mutate(narr_cell = raster::cellFromXY(r_narr_empty, as(d, "Spatial")))

# map across all unique narr_cell numbers, also specifying the date range and variables we want
# (start_date, end_date, narr_variables could also be omitted to return all variables and dates by default

d_narr <-
  purrr::map_dfr(
    unique(d[["narr_cell"]]),
    get_narr_data,
    start_date = as.Date("2015-01-01"),
    end_date = as.Date("2019-01-01"),
    narr_variables = c("air.2m", "rhum.2m", "prate")
  )

## TODO do some stuff to aggregate and/or merge this data back to a tabular format and then write out
