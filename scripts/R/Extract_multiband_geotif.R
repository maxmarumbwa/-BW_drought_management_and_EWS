# Load necessary libraries
library(terra)

# Load the multiband GeoTIFF

file_path <- "C:/data/rfe_chirp_anom_per_2015.tif"
raster_data <- rast(file_path)

# Display the names of each band
band_names <- names(raster_data)
print(band_names)

# Plot each band separately
n_bands <- nlyr(raster_data)
for (i in 1:n_bands) {
  plot(raster_data[[i]], main = paste("Band", i))
}


# Export to individual file names

# Retrieve band names
band_names <- names(raster_data)

# Export each band using its original band name
for (i in 1:length(band_names)) {
  # Extract the i-th band
  band <- raster_data[[i]]
  
  # Define output file path using the band name
  output_path <- paste0("C:/data/", band_names[i], ".tif")
  
  # Save the band as a separate GeoTIFF file
  writeRaster(band, output_path, overwrite = TRUE)
  cat("Saved", band_names[i], "to", output_path, "\n")
}













