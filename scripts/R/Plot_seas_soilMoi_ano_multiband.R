rm(list = ls())

# Load required libraries
library(terra)
library(here)
library(rasterVis) # For levelplot
library(sf)        # For handling shapefiles
library(raster)

# Set file paths
## Soil_moisture data starts from 2016-2023
multiband_file <- here("data", "input", "Remote sensing","Soilm1mDavgP_smap","Soilm1mDavgP_smap_2016_2023.tif")

# Define the period (October 2015 to April 2016)
start_date <- as.Date("2022-10-01")
end_date <- as.Date("2023-05-30")
dates <- seq(start_date, end_date, by = "month")

# Extract date strings to match raster bands (e.g., "201507")
date_strings <- format(dates, "%Y%m")

# Load the multiband raster file
raster_multiband <- rast(multiband_file)
names(raster_multiband)

# Filter bands by matching date strings
filtered_bands <- which(names(raster_multiband) %in% date_strings)
raster_filtered <- raster_multiband[[filtered_bands]]

# Rename bands with readable labels (e.g., "Jul 2015")
band_names <- format(dates[filtered_bands], "%b %Y")
names(raster_filtered) <- band_names

# Convert terra raster to RasterStack for rasterVis compatibility
raster_stack_raster <- stack(raster_filtered)

# Define the custom color palette and breaks
color_palette <- c('#d53e4f', 'red', '#fc8d59', '#fee08b', '#f5f5f5', '#e6f598', '#99d594', '#6488bd', '#3288bd')
breaks <- c(-3, -2, -1.5, -1, -0.5, 0.5, 1, 1.5, 2, 3)

# Plot using levelplot
levelplot(raster_stack_raster,
          col.regions = color_palette,
          at = seq(-3, 3, length.out = length(color_palette) + 1), # Adjust breaks based on data range
          main = list(label = "Rainfall Anomalies 2015-2016 Season", cex = 1),
          scales = list(draw = TRUE),  # Ensures axes are drawn
          colorkey = list(space = "right")) # Place legend on the right

######## Add shapefile and overlay ####
# Load shapefiles
shapefile_path <- here("data", "shapefiles", "WEAP_main_catchments_reproj.shp")
bw_shapefile_path <- "data/shapefiles/Botswana_country.shp"

catchment_shp <- st_read(shapefile_path)
bw_shp <- st_read(bw_shapefile_path)

# Convert sf objects to Spatial for compatibility with rasterVis
catchment_shp_sp <- as(catchment_shp, "Spatial")
bw_shp_sp <- as(bw_shp, "Spatial")

levelplot(
  raster_stack_raster,
  main = list(label = "Rainfall Anomalies 2015-2016 Season", cex = 1),
  col.regions = color_palette,
  at = breaks,
  names.attr = names(raster_stack_raster),
  par.settings = list(strip.background = list(col = "white")),
  layout = c(4, 2),
  panel = function(...) {
    panel.levelplot(...)  # Plot raster
    sp::sp.polygons(catchment_shp_sp, col = "black", lwd = 1.5)  # Overlay catchment shapefile
    sp::sp.polygons(bw_shp_sp, col = "grey", lwd = 1.5)  # Overlay additional shapefile
    
    # Add catchment names
    catchment_coords <- coordinates(catchment_shp_sp)
    catchment_names <- catchment_shp_sp@data$name
    panel.text(catchment_coords[,1], catchment_coords[,2], labels = catchment_names, cex = 0.6, col = "black")
  }
)
