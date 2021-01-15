# narr_raster_to_fst

- [NARR](https://www.esrl.noaa.gov/psd/data/gridded/data.narr.html) data details
- update on 1/15/21: `narr.fst` now includes NARR data from 2000 through 2020

## computing environment

In addition to the package dependencies documented in `renv`, this repo relies on the `aws cli` being available. It relies heavily on system calls and so its behavior may change depending on the host operating system. Ideally, the `cole-brokamp/singr` singularity image would be used to run the scripts.

## creating fst file

- `01_narr_to_fst.R` downloads, extracts, and converts all NARR data to `.qs` files
    - each file is saved in the `./narr` directory and named according to variable and year
- `02_convert_to_DT_fst.R` merges all `.qs` files and saves them as one `.fst` file (`./narr.fst`)
- `03_create_empty_raster.R` downloads raster file to get info to use to create "empty raster" for lookup purposes

## fst file structure

- The fst file (`narr.fst`) is stored at `s3://geomarker/narr/narr.fst`
- It is a data.table object in long format with ordered key columns `narr_cell` and `date`, useful for data.table lookups.
- Other columns are the different NARR variables: `hpbl`, `vis`, `uwnd.10m`, `vwnd.10m`, `air.2m`, `rhum.2m`, `prate`, and `pres.sfc`.
- The data.table object has 706,196,265 rows and 10 columns. (96,673 unique NARR cells, each with 7,305 unique dates)
- It occupies about 51.2 GB in RAM and about 21 GB when on disk as a compressed fst file. (Smaller versions can be queried on disk by specifying which rows and columns are needed -- see below.)

## getting data for an sf object

An "empty raster" that can be quickly used to match geospatial features with NARR cells can also be found in `get_narr_data.R`

See the example file `_example_point_extraction.R` for how to implement code to extract values for sf points

## reading data from fst file

Functions for extracting values for a cell number, date, and variable combination can be found in `get_narr_data.R`.

The `narr.fst` file is ordered first by narr cell number and then by date, so the first 7,305 rows are for narr cell 1, row 7,306 to row 14,610 are for narr cell 2, and so on. In general, you can convert a narr cell number to a range of row numbers as: [((narr_cell_number - 1) * 7305) + 1, narr_cell_number * 7305].

*Functions for extracting NARR data given a cell number and date range are now available in the [addNarrData](https://github.com/geomarker-io/addNarrData) as well.*
