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


# Plot using same legend
# Define a color palette and breaks for the legend
#color_palette <- colorRampPalette(c("red", "white", "blue"))
color_palette <- colorRampPalette(c('#d73027','#fc8d59','#fee08b','#ffffbf','#d9ef8b','#91cf60','#1a9850'))

breaks <- seq(-300, 300, by = 10)  # Adjust range based on your data


# Plot with overlay and reduced title size
levelplot(
  Rfe_Perc_ano_stack,
  main = list(label = "Rainfall Anomaly (%) for 2015-2016 Season", cex = 0.8),  # Reduce title size
  col.regions = color_palette,
  at = breaks,
  names.attr = names(Rfe_Perc_ano_stack),  # Use the modified layer names as titles
  par.settings = list(strip.background = list(col = "lightgrey")),
  layout = c(1, 1),  # Adjust for desired layout
  panel = function(...) {
    panel.levelplot(...)  # Plot raster
    sp::sp.polygons(catchment_shp_sp, col = "black", lwd = 1.5)  # Overlay shapefile boundaries
    
    # Add catchment names
    catchment_coords <- coordinates(catchment_shp_sp)  # Get coordinates for labels
    catchment_names <- catchment_shp_sp@data$name      # Access "name" attribute in shapefile
    panel.text(catchment_coords[,1], catchment_coords[,2], labels = catchment_names, cex = 0.6, col = "black")
  }
)

