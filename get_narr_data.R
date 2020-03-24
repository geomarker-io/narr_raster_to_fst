r_narr_empty <-
  raster::raster(
    nrows = 277,
    ncols = 349,
    xmn = -16231.49,
    xmx = 11313351,
    ymn = -16231.5,
    ymx = 8976020,
    crs = "+proj=lcc +x_0=5632642.22547 +y_0=4612545.65137 +lat_0=50 +lon_0=-107 +lat_1=50",
    resolution = c(32462.99, 32463),
    vals = NULL
  )

# read in narr data for specified narr cell, dates, and variables
# returns a data.table indexed on narr_cell and date for further manipulation
get_narr_data <- function(narr_cell_number,
                          start_date = as.Date("2000-01-01"),
                          end_date = as.Date("2019-12-31"),
                          narr_variables = c(
                            "hpbl", "vis", "uwnd.10m", "vwnd.10m",
                            "air.2m", "rhum.2m", "prate", "pres.sfc"
                          )) {
  if (length(narr_cell_number) > 1) {
    stop("nlcd_cell should only be a single value")
  }
  date_seq <- seq.Date(start_date, end_date, by = 1)
  narr_row_start <- ((narr_cell_number - 1) * 7305) + 1
  narr_row_end <- narr_cell_number * 7305
  out <-
    fst::read_fst(
      path = "./narr.fst",
      from = narr_row_start,
      to = narr_row_end,
      columns = c("narr_cell", "date", narr_variables),
      as.data.table = TRUE
    )
  out <- out[.(data.table::CJ(narr_cell_number, date_seq)), nomatch = 0L]
  tibble::as_tibble(out)
}

# get_narr_data(narr_cell_number = 56772)

## expected error
# get_narr_data(c(56772, 57121, 56773))
