rm(list = ls())

# Load required libraries
library(terra)
library(here)
library(gridExtra)
library(ggplot2)
library(sf) # For handling shapefiles

# Set paths
input_dir <- here("output", "spei_geotiffs", "spei12")
shapefile_path <- here("data", "shapefiles", "WEAP_main_catchments_reproj.shp")

# Define the period (July 2015 to June 2016)
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

# Load the shapefile
aoi_shapefile <- st_read(shapefile_path)

# Define the SPEI color scale
spei_colors <- colorRampPalette(c("darkred", "red", "orange", "yellow", "white", "lightblue", "blue", "darkblue"))(100)

# Plot each raster with ggplot, including the shapefile overlay
plot_list <- lapply(seq_along(raster_list), function(i) {
  # Convert raster to a data frame for ggplot
  df <- as.data.frame(raster_list[[i]], xy = TRUE, na.rm = TRUE)
  colnames(df)[3] <- "value"
  
  # Extract the date from the file name
  plot_date <- format(dates[i], "%b %Y")
  
  # Create the plot
  ggplot() +
    geom_raster(data = df, aes(x = x, y = y, fill = value)) +
    scale_fill_gradientn(colors = spei_colors, limits = c(-2.5, 2.5), na.value = "transparent") +
    geom_sf(data = aoi_shapefile, fill = NA, color = "black", size = 0.9) + # Overlay the shapefile
    labs(title = paste("", plot_date), fill = "SPEI") +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 10, face = "bold"),
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      legend.position = "bottom",
      legend.title = element_text(size = 8), # Reduce legend title size
      legend.text = element_text(size = 6)  # Reduce legend text size
    )
})

# Arrange all plots on one page
grid.arrange(grobs = plot_list, ncol = 4)

