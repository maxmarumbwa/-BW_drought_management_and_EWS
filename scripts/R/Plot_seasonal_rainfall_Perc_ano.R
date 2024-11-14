rm(list = ls())
library(raster)
library(sf)          # For reading shapefiles
library(rasterVis)   # For enhanced raster plotting
library(here)


# Define paths
raster_path <- "data/input/Remote sensing/rfe_Perc_ano/2015_2016/"
shapefile_path <-"data/shapefiles/WEAP_main_catchments_reproj.shp"

# Load raster stack
raster_files <- list.files(path = raster_path, pattern = "\\.tif$", full.names = TRUE)
Rfe_Perc_ano_stack <- stack(raster_files)

# Load shapefile.
catchment_shp <- st_read(shapefile_path)

# Convert sf object to Spatial object for use with rasterVis
catchment_shp_sp <- as(catchment_shp, "Spatial")

# layer names
print(names(Rfe_Perc_ano_stack))
"X6_rfe_chirp_month_anom_per_201507"
# Rename each layer in the stack by modifying the date part
names(Rfe_Perc_ano_stack) <- sapply(names(Rfe_Perc_ano_stack), function(layer_name) {
  # Extract the date part at the end of the layer name (e.g., "201601")
  date_part <- substr(layer_name, nchar(layer_name) - 5, nchar(layer_name))
  #resulting file "X201507"
  # remove the "X" prefix   . Not working
  new_date_part <- gsub("X", " ", date_part)
  # Return the new name for the layer
  return(new_date_part)
})
#plot all years
plot(Rfe_Perc_ano_stack)

# Plot the raster layer
plot_layer <- Rfe_Perc_ano_stack[[1]]

# Plot the raster layer with the shapefile overlay
levelplot(plot_layer, 
          margin = FALSE,
          main = "Rainfall Anomaly with Catchment Boundaries") +
  layer(sp.polygons(catchment_shp_sp, col = "black", lwd = 1.5))

