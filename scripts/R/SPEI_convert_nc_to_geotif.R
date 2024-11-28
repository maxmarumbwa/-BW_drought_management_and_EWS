rm(list = ls())
library(terra)
library(here)
# SPEImm_csic_yyyymm

# Define input NetCDF file and shapefile
nc_file <- here("data", "input", "Remote sensing", "spei", "spei12.nc")
shapefile <- here("data", "shapefiles", "AOI_Shapefile_Export.shp")

# Load the NetCDF file as a SpatRaster
raster_data <- rast(nc_file)

# Load the shapefile
clip_shape <- vect(shapefile)

# Extract time values from the raster
time_values <- time(raster_data)

# Convert time values to Date format
dates <- as.Date(time_values, origin = "1970-01-01")

# Filter layers for years >= 1981
start_date <- as.Date("1981-01-01")
indices <- which(dates >= start_date)

# Directory to save output GeoTIFFs
output_dir <- here("output", "spei_geotiffs", "spei12")
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Loop through filtered layers, clip, and save as GeoTIFF
for (i in indices) {
  # Get the time for the current layer
  current_date <- dates[i]
  
  # Format the date as "YYYY-MM" (remove day component)
  date_str <- format(current_date, "%Y%m")
  
  # Clip the raster layer using the shapefile
  clipped_raster <- mask(crop(raster_data[[i]], clip_shape), clip_shape)
  
  # Define output file name
  output_file <- file.path(output_dir, paste0("Spei012_csic_", date_str, ".tif"))
  
  # Write the clipped layer as a GeoTIFF
  writeRaster(clipped_raster, output_file, overwrite = TRUE)
  
  # Print progress
  cat("Saved:", output_file, "\n")
}

cat("All clipped layers from 1981 onwards have been saved to GeoTIFFs in", output_dir, "\n")
