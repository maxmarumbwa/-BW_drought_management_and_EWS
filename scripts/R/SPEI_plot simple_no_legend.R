rm(list = ls())

# Load required libraries
library(terra)
library(here)
library(rasterVis) # For levelplot
library(sf)        # For handling shapefiles
library(raster)

# Set paths
input_dir <- here("output", "spei_geotiffs", "spei12")
shapefile_path <- here("data", "shapefiles", "WEAP_main_catchments_reproj.shp")

# Define the period (October 2017 to April 2018)
start_date <- as.Date("2017-10-01")
end_date <- as.Date("2018-04-30")

# Generate a list of expected file names for this period
dates <- seq(start_date, end_date, by = "month")
file_names <- paste0("Spei12_csic_", format(dates, "%Y%m"), ".tif")

# Load the GeoTIFF files for the specified period
file_paths <- file.path(input_dir, file_names)
raster_list <- lapply(file_paths, function(fp) {
  if (file.exists(fp)) rast(fp) else NULL
})

# Remove any missing files
raster_list <- raster_list[!sapply(raster_list, is.null)]

# Stack the rasters into a single object for plotting
raster_stack <- rast(raster_list)
plot(raster_stack)
