
rm(list = ls())

# Load required libraries
library(terra)
library(here)
library(rasterVis) # For levelplot
library(sf)        # For handling shapefiles
library(raster)

# Set paths
input_dir <- here("output", "spei_geotiffs", "spei03")
shapefile_path <- here("data", "shapefiles", "WEAP_main_catchments_reproj.shp")
bw_shapefile_path <- "data/shapefiles/Botswana_country.shp"

# Define the period (October 2017 to April 2018)
start_date <- as.Date("2015-10-01")
end_date <- as.Date("2016-05-30")

# Generate a list of expected file names for this period
dates <- seq(start_date, end_date, by = "month")
file_names <- paste0("Spei03_csic_", format(dates, "%Y%m"), ".tif")

# Extract readable labels from file names
layer_names <- format(dates, "%b %Y")  # Converts dates to "Month Year" format

# Load the GeoTIFF files for the specified period
file_paths <- file.path(input_dir, file_names)
raster_list <- lapply(file_paths, function(fp) {
  if (file.exists(fp)) rast(fp) else NULL
})

# Remove any missing files
raster_list <- raster_list[!sapply(raster_list, is.null)]

# Stack the rasters into a single object for plotting
raster_stack <- rast(raster_list)

# Convert terra raster stack to RasterStack for rasterVis
raster_stack_raster <- stack(raster_stack)

# Rename layers in the RasterStack based on input file names
names(raster_stack_raster) <- layer_names


# Define the custom color palette
#color_palette <- c('#d53e4f','#fc8d59','#fee08b','#f5f5f5','#e6f598','#99d594','#3288bd')
color_palette <- c('#d53e4f','red','#fc8d59','#fee08b','#f5f5f5','#e6f598','#99d594','#6488bd','#3288bd')

breaks <- c(-3,-2, -1.5, -1, -0.5, 0.5, 1, 1.5, 2,3) 

### Plot using levelplot with updated layer names - NO OVERLAY
# levelplot(raster_stack_raster, 
#           col.regions = color_palette, 
#           at = seq(-3, 3, length.out = length(color_palette) + 0.5), # Adjust breaks based on data range
#           main = list(label = "1 Month SPEI for 2015-2016 Season", cex = 1),
#           scales = list(draw = TRUE),  # Ensures axes are drawn
#           colorkey = list(space = "right")) # Place legend on the right
# 

########------- Add shapefile and plot the map ----- ####
# Load shapefiles
catchment_shp <- st_read(shapefile_path)
bw_shp <- st_read(bw_shapefile_path)

# Convert sf objects to Spatial objects for compatibility with rasterVis
catchment_shp_sp <- as(catchment_shp, "Spatial")
bw_shp_sp <- as(bw_shp, "Spatial")

levelplot(
  raster_stack_raster,
  main = list(label = "3 Month SPEI for 2015-2016 Season", cex = 1),  # Reduce title size
  col.regions = color_palette,
  at = breaks,
  names.attr = names(raster_stack_raster),  # Use the modified layer names as titles
  par.settings = list(strip.background = list(col = "white")),
  layout = c(4, 2),  # Adjust for desired layout
  panel = function(...) {
    panel.levelplot(...)  # Plot raster
    sp::sp.polygons(catchment_shp_sp, col = "black", lwd = 1.5)  # Overlay main catchment shapefile
    sp::sp.polygons(bw_shp_sp, col = "grey", lwd = 1.5)  # Overlay additional shapefile in red
    
    # Add catchment names
    catchment_coords <- coordinates(catchment_shp_sp)  # Get coordinates for labels
    catchment_names <- catchment_shp_sp@data$name      # Access "name" attribute in shapefile
    panel.text(catchment_coords[,1], catchment_coords[,2], labels = catchment_names, cex = 0.6, col = "black")
  }
)




###############################################################


















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

# Plot the raster stack
plot(raster_stack)
# Add a single title across all graphs
mtext("SPEI12 Analysis: October 2017 to April 2018", side = 3, outer = TRUE, line = -1.5, cex = 1.5)

levelplot(
  raster_stack,main = list(label = "3 Month SPEI for 2015-2016 Season"), cex = 0.8,  # Reduce title size
  col.regions = color_palette,
  at = breaks
)


############### Divergent colorsbt no dates on file name

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

# Extract readable labels from file names
layer_names <- format(dates, "%B %Y")  # Converts dates to "Month Year" format

# Load the GeoTIFF files for the specified period
file_paths <- file.path(input_dir, file_names)
raster_list <- lapply(file_paths, function(fp) {
  if (file.exists(fp)) rast(fp) else NULL
})

# Remove any missing files
raster_list <- raster_list[!sapply(raster_list, is.null)]

# Stack the rasters into a single object for plotting
raster_stack <- rast(raster_list)

# Convert terra raster stack to RasterStack for rasterVis
raster_stack_raster <- stack(raster_stack)

# Rename layers in the RasterStack based on input file names
names(raster_stack_raster) <- layer_names

# Define the custom color palette
color_palette <- c('#d53e4f','#fc8d59','#fee08b','#f5f5f5','#e6f598','#99d594','#3288bd')

# Plot using levelplot with updated layer names
levelplot(raster_stack_raster, 
          col.regions = color_palette, 
          at = seq(-3, 3, length.out = length(color_palette) + 1), # Adjust breaks based on data range
          main = "SPEI12 Analysis: October 2017 to April 2018",
          scales = list(draw = TRUE),  # Ensures axes are drawn
          colorkey = list(space = "right")) # Place legend on the right

######################