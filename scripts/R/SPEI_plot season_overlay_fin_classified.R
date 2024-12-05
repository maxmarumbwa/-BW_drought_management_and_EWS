
rm(list = ls())

# Load required libraries
library(terra)
library(here)
library(rasterVis) # For levelplot
library(sf)        # For handling shapefiles
library(raster)

# Set paths
input_dir <- here("output", "spei_geotiffs", "spei06")
shapefile_path <- here("data", "shapefiles", "WEAP_main_catchments_reproj.shp")
bw_shapefile_path <- "data/shapefiles/Botswana_country.shp"

# Define the period (October 2017 to April 2018)
start_date <- as.Date("2016-01-01")
end_date <- as.Date("2016-05-30")

# Generate a list of expected file names for this period
dates <- seq(start_date, end_date, by = "month")
file_names <- paste0("Spei06_csic_", format(dates, "%Y%m"), ".tif")

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
# color_palette <- c('#d53e4f','red','#fc8d59','#fee08b','#f5f5f5',
#                    '#e6f598','#99d594','#6488bd','#3288bd')
# breaks <- c(-3,-2, -1.5, -1, -0.5, 0.5, 1, 1.5, 2,3) 

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


# Define the fixed classification breaks, color palette, and class labels
breaks <- c(-Inf, -2.00, -1.99, -1.49, -0.99, -0.49, 0.49, 0.99, 1.49, 1.99, Inf)
color_palette <- c('#d53e4f','red','#fc8d59','#fee08b','#f5f5f5',
                   '#e6f598','#99d594','#6488bd','#3288bd')
legend_labels <- c("Extremely dry", "Severely dry", "Moderately dry", "Mild dry", 
                   "Near normal", "Slightly wet", "Moderately wet", "Severely wet", "Extremely wet")

# Plotting with all classes always displayed in the legend
levelplot(
  raster_stack_raster,
  main = list(label = "6 Month SPEI for 2015-2016 Season", cex = 1),
  col.regions = color_palette,
  at = breaks,
  names.attr = names(raster_stack_raster),  # Use modified layer names as titles
  par.settings = list(strip.background = list(col = "white")),
  layout = c(4, 2),  # Adjust for desired layout
  colorkey = list(
    space = "right",  # Place legend on the right
    labels = list(
      at = seq(-2.5, 2.5, length.out = length(legend_labels)),  # Ensure all classes are included
      labels = legend_labels,  # Class names as labels
      cex = 0.8  # Adjust font size of the labels
    ),
    col = color_palette  # Ensure all colors are shown, even if not in data
  ),
  panel = function(...) {
    panel.levelplot(...)  # Plot raster
    sp::sp.polygons(catchment_shp_sp, col = "black", lwd = 1.5)  # Overlay main catchment shapefile
    sp::sp.polygons(bw_shp_sp, col = "grey", lwd = 1.5)  # Overlay additional shapefile
    
    # Add catchment names
    catchment_coords <- coordinates(catchment_shp_sp)  # Get coordinates for labels
    catchment_names <- catchment_shp_sp@data$name      # Access "name" attribute in shapefile
    panel.text(catchment_coords[,1], catchment_coords[,2], 
               labels = catchment_names, cex = 0.6, col = "black")
  }
)



###############################################################


