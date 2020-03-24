library(ncdf4)

download.file(
  "ftp://ftp.cdc.noaa.gov/Datasets/NARR/Dailies/monolevel/hpbl.2000.nc",
  destfile = "hpbl.2000.nc"
)

r_narr <- raster::brick("hpbl.2000.nc")

r_narr

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

raster::compareRaster(r_narr, r_narr_empty, values = FALSE)
