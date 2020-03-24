library(data.table)
library(glue)
library(magrittr)

nms <- c("hpbl", "vis", "rhum.2m", "prate", "air.2m", "pres.sfc", "uwnd.10m", "vwnd.10m")

read_and_convert <- function(nm) {
  purrr::map(
    as.character(2000:2019),
    ~ qs::qread(glue::glue("./narr/narr_{nm}_{.}.qs"), nthreads = parallel::detectCores())
  ) %>%
    dplyr::bind_rows() %>%
    as.data.table(key = c("narr_cell", "date"))
}

# create data.table for needed dates and grid combos

narr_cells <- 1:96673
dates <- seq.Date(as.Date("2000-01-01"), as.Date("2019-12-31"), 1)

d <-
  tibble::tibble(
    narr_cell = rep(narr_cells, each = length(dates)),
    date = rep(dates, times = length(narr_cells))
  ) %>%
  as.data.table(key = c("narr_cell", "date"))

rm(narr_cells, dates)

# iteratively read and merge each one
# cleanup as we go to save RAM
# notably, the data.table merge will update in place, saving RAM

d_hpbl <- read_and_convert("hpbl")
d[d_hpbl, on = .(narr_cell, date), hpbl := i.hpbl]
rm(d_hpbl)

d_vis <- read_and_convert("vis")
d[d_vis, on = .(narr_cell, date), vis := i.vis]
rm(d_vis)

d_uwnd.10m <- read_and_convert("uwnd.10m")
d[d_uwnd.10m, on = .(narr_cell, date), uwnd.10m := i.uwnd.10m]
rm(d_uwnd.10m)

d_vwnd.10m <- read_and_convert("vwnd.10m")
d[d_vwnd.10m, on = .(narr_cell, date), vwnd.10m := i.vwnd.10m]
rm(d_vwnd.10m)

d_air.2m <- read_and_convert("air.2m")
d[d_air.2m, on = .(narr_cell, date), air.2m := i.air.2m]
rm(d_air.2m)

d_rhum.2m <- read_and_convert("rhum.2m")
d[d_rhum.2m, on = .(narr_cell, date), rhum.2m := i.rhum.2m]
rm(d_rhum.2m)

d_prate <- read_and_convert("prate")
d[d_prate, on = .(narr_cell, date), prate := i.prate]
rm(d_prate)

d_pres <- read_and_convert("pres.sfc")
d[d_pres, on = .(narr_cell, date), pres.sfc := i.pres.sfc]
rm(d_pres)

# save it
fst::write_fst(d, "narr.fst", compress = 100)

# data check:

# should be 7,305 dates per cell
d[, .N, by = narr_cell][, .N, by = N]

# should be 96,673 cells per date
d[, .N, by = date][, .N, by = N]
