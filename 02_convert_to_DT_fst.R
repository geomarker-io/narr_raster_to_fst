library(data.table)
library(dplyr)
library(tidyr)
library(glue)
library(magrittr)

nms <- c("hpbl", "vis", "rhum.2m", "prate", "air.2m", "pres.sfc", "uwnd.10m", "vwnd.10m")

narr_cells <- 1:96673
dates <- seq.Date(as.Date("2000-01-01"), as.Date("2020-12-31"), 1)

d <-
  tibble::tibble(
    narr_cell = rep(narr_cells, each = length(dates)),
    date = rep(dates, times = length(narr_cells))
  ) %>%
  as.data.table(key = c("narr_cell", "date"))

rm(narr_cells, dates)

read_and_convert <- function(nm = "hpbl") {

  dir.create("narr_chunk_fst", showWarnings = FALSE)

  d_read <-
    purrr::map(
      as.character(2000:2020),
      ~ qs::qread(glue::glue("./narr_qs/narr_{nm}_{.}.qs"), nthreads = 8)
      ## ~ qs::qread(glue::glue("./narr_qs/narr_{nm}_{.}.qs"), nthreads = 8)
    ) %>%
    dplyr::bind_rows() %>%
    as.data.table(key = c("narr_cell", "date"))

  d_full_seq <-
    data.table::merge.data.table(
      d,
      d_read,
      all.x = TRUE,
      by = c("narr_cell", "date")
    )

  dd <-
    d_full_seq %>%
    mutate(narr_chunk = narr_cell %/% 10000) %>%
    group_nest(narr_chunk)

  dd$data <- purrr::map(dd$data, as.data.table, key = c("narr_cell", "date"))

  purrr::walk2(
    dd$narr_chunk,
    dd$data,
    ~ fst::write_fst(
      .y,
      glue::glue("./narr_chunk_fst/narr_chunk_{.x}_{nm}.fst"),
      compress = 100
    )
  )

}

purrr::walk(nms, read_and_convert)

# save it all to s3
system("aws s3 sync narr_chunk_fst s3://geomarker/narr/narr_chunk_fst")

