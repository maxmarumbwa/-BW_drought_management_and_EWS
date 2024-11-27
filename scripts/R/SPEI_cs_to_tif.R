rm(list = ls())
library(terra)
library(here)

# Define input NetCDF file
nc_file <- here("data", "input", "Remote sensing", "spei", "spei03.nc")

# Load the NetCDF file as a SpatRaster
raster_data <- rast(nc_file)
print(raster_data[[1]])
#plot(raster_data[[1]])

# Extract time values from the raster
time_values <- time(raster_data)

# Directory to save output GeoTIFFs
output_dir <- here("data", "output", "SPEI geotif", "spei_03")
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

nlyr(raster_data)

# Loop through each time slice and save as GeoTIFF
for (i in 1:nlyr(raster_data)) {
  # Get the time for the current layer
  current_time <- time_values[i]
  
  # Format the time as "YYYY-MM-DD"
  time_str <- format(as.Date(current_time, origin = "1970-01-01"), "%Y-%m-%d")
  
  # Define output file name
  output_file <- file.path(output_dir, paste0("SPEI_", time_str, ".tif"))
  
  # Extract the layer and write it as a GeoTIFF
  writeRaster(raster_data[[i]], output_file, overwrite = TRUE)
  
  # Print progress
  cat("Saved:", output_file, "\n")
}

cat("All layers have been saved to GeoTIFFs in", output_dir, "\n")








# Load the NetCDF file
nc_file <- "data/input/Remote sensing/spei/spei03.nc"
raster_data <- rast(nc_file)

print(raster_data[[1]])

plot(raster_data[[1]])

# Specify the output GeoTIFF file name
output_tif <- "data/input/Remote sensing/spei02.tif"

# Write the data to a GeoTIFF
writeRaster(raster_data, output_tif, format = "GTiff", overwrite = TRUE)

cat("Conversion completed: ", output_tif)
