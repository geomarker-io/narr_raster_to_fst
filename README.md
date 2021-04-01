# narr_raster_to_fst

- [NARR](https://www.esrl.noaa.gov/psd/data/gridded/data.narr.html) data details
- update on 1/15/21: `narr.fst` now includes NARR data from 2000 through 2020
- update on 4/1/2021: distribute data in smaller chunks

## computing environment

In addition to the package dependencies documented in `renv`, this repo relies on the `aws cli` being available. It relies heavily on system calls and so its behavior may change depending on the host operating system. Ideally, the `cole-brokamp/singr` singularity image would be used to run the scripts.

## creating fst files

- `01_narr_to_fst.R` downloads, extracts, and converts all NARR data to `.qs` files
    - each file is saved in the `./narr_qs` directory and named according to variable and year
- `02_convert_to_DT_fst.R` merges `.qs` files and saves them into chunked files for each variable
- `03_create_empty_raster.R` downloads raster file to get info to use to create "empty raster" for lookup purposes

## fst files structure

- The absolute s3 location of a NARR data chunk file is:

```
s3://geomarker/narr/narr_chunk_fst/narr_chunk_{number}_{variable}.fst
```

where `{number}` is replaced with the NARR chunk number, defined as `narr_cell %/% 10000`, and `{variable}` is replaced with one of the available NARR variables (`hpbl`, `vis`, `rhum.2m`, `prate`, `air.2m`, `pres.sfc`, `uwnd.10m`, `vwnd.10m`)

There are 10 total chunk files (0 - 9) for each NARR variable. Each file contains columns for `narr_cell`, `date`, and the NARR variable it contains (e.g., `hpbl`). The files are `data.table` objects (and can be read in as such using `fst::fst_read()`) with preset keys on `narr_cell` and `date`, useful for data.table lookups and merges.

An R example of how to read in `air.2m` for `narr_cell` 56772:

```r
narr_cell <- 56772
narr_chunk <- narr_cell %/% 10000
narr_product <- "air.2m"

s3::s3_get(glue::glue("s3://geomarker/narr/narr_chunk_{narr_chunk}_{narr_product}.fst")) %>%
fst::read_fst(as.data.table = TRUE)
```

This file could then be data.table merged onto an existing data.table with `narr_cell` and `date`. 

Compared to using a single large file, this prevents any confusing conversions between `narr_cell` and row numbers and could prevent future problems when the data is updated.


## addNarrData

This repository serves as a means to generate data for the [addNarrData](https://github.com/geomarker-io/addNarrData) R package, which contains functions for extracting NARR data given a cell number or latitude/longitude coordinate.
