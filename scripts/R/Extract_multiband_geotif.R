# Load necessary libraries
library(terra)

# Load the multiband GeoTIFF

file_path <- "C:/data/rfe_chirp_anom_per_2015.tif"
raster_data <- rast(file_path)

# Plot each band separately
n_bands <- nlyr(raster_data)
for (i in 1:n_bands) {
  plot(raster_data[[i]], main = paste("Band", i))
}


# Export to individual file names

# Load the necessary library
if (!require(terra)) install.packages("terra")
library(terra)

# Load the multiband GeoTIFF
file_path <- "C:/data/rfe_chirp_anom_per_2015.tif"
raster_data <- rast(file_path)

# Get the base file name (without extension)
base_name <- tools::file_path_sans_ext(basename(file_path))

# Check the number of bands
n_bands <- nlyr(raster_data)

# Extract and save each band with the original file name as a prefix
for (i in 1:n_bands) {
  # Extract the i-th band
  band <- raster_data[[i]]
  
  # Define output file path
  output_path <- paste0("C:/data/", base_name, "_0", i, ".tif")
  
  # Save the band as a separate GeoTIFF file
  writeRaster(band, output_path, overwrite = TRUE)
  cat("Saved band", i, "to", output_path, "\n")
}




















