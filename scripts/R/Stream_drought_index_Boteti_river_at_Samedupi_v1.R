rm(list = ls())
library(readxl)
library(SPEI)
library(dplyr)


#load the input files
infile <- read_excel("data/input/WEAP/input/Model_streamflow/Boteti_river_at_Samedupi.xlsx",
         sheet = "Sheet2")
colnames(infile) <- c("Date","Streamflow")
station_name <- "Botetiriver at Samedupi"
#infile<- read_excel("data/input/WEAP/input/Model_streamflow/Limpopo_at_Buffels.xlsx", 
#                               sheet = "Sheet2")
#colnames(infile) <- c("Date","Streamflow")   
# # error sum last column
#infile<- read_excel("data/input/WEAP/input/Model_streamflow/Limpopo_at_Seleka.xlsx",                                 sheet = "Sheet2", col_types = c("date","numeric"))
#  colnames(infile) <- c("Date","Streamflow")   
#infile<- read_excel("data/input/WEAP/input/Model_streamflow/Ntse_at_Ntse_weir.xlsx", 
#                                sheet = "Sheet2", col_types = c("date","numeric"))
# #colnames(infile) <- c("Date","Streamflow")   
# infile<- read_excel("data/input/WEAP/input/Model_streamflow/Okavango_at_Mohembo.xlsx", 
#                                   sheet = "Sheet2", col_types = c("date","numeric"))
# colnames(infile) <- c("Date","Streamflow")   
#infile<- read_excel("data/input/WEAP/input/Model_streamflow/Tati_at_Tati_weir.xlsx", 
#                              sheet = "Sheet2", col_types = c("date","numeric"))
#colnames(infile) <- c("Date","Streamflow")   
#infile<- read_excel("data/input/WEAP/input/Model_streamflow/Thamalakane_at_Maun_bridge.xlsx", 
#                                         sheet = "Sheet2", col_types = c("date","numeric"))
#colnames(infile) <- c("Date","Streamflow")   

# Convert daily data to monthly totals
monthly_streamflow_data <- infile %>%
  mutate(year_month = format(Date, "%Y-%m")) %>%
  group_by(year_month) %>%
  summarise(Streamflow = sum(Streamflow))

# Append the day day to yyyymm
monthly_streamflow_data$date <- as.Date(paste0(monthly_streamflow_data$year_month, "-01"))

# Calculate the stream flow Drought index SDI for a 1,3,6-month scale
SDI_data_1m <- spi(monthly_streamflow_data$Streamflow, 1, distribution = 'Gamma')
SDI_data_3m <- spi(monthly_streamflow_data$Streamflow, 3, distribution = 'Gamma')
SDI_data_6m <- spi(monthly_streamflow_data$Streamflow, 6, distribution = 'Gamma')


# Append SDI to df
monthly_streamflow_data$Streamflow_drought_index_1m <- SDI_data_1m$fitted
monthly_streamflow_data$Streamflow_drought_index_3m <- SDI_data_3m$fitted
monthly_streamflow_data$Streamflow_drought_index_6m <- SDI_data_6m$fitted

# Replace -Inf with NA (missing data) helpful in analyses and prevent graphing errors
#A value of -Inf (negative infinity) generally occurs when the data for a particular period is 
# zero or near-zero across the entire range used to calculate the index
monthly_streamflow_data$Streamflow_drought_index_1m[is.infinite(monthly_streamflow_data$Streamflow_drought_index_1m)] <- NA
monthly_streamflow_data$Streamflow_drought_index_3m[is.infinite(monthly_streamflow_data$Streamflow_drought_index_3m)] <- NA
monthly_streamflow_data$Streamflow_drought_index_6m[is.infinite(monthly_streamflow_data$Streamflow_drought_index_6m)] <- NA

# save the SDI
write.csv(monthly_streamflow_data, "output/csv/paste("station_name",.csv", row.names = FALSE)

# # Plot the SDI values over time
plot(monthly_streamflow_data$date, monthly_streamflow_data$Streamflow_drought_index_6m, type = 'l', col = 'blue',
     xlab = 'Date', ylab = 'SDI', main = 'Streamflow drought Index Tati weir')

head(monthly_streamflow_data)

# Plot the SPI values over time as a bar plot
barplot(
  height = monthly_streamflow_data$Streamflow_drought_index_1m,
  names.arg = monthly_streamflow_data$year_month,
  col = ifelse(monthly_streamflow_data$Streamflow_drought_index_1m >= 0, "blue", "red"),
  xlab = 'Date',
  ylab = 'Stream flow drought Index (SDI)',
  main = station_name,
  las = 2, # Rotate x-axis labels for better readability
  cex.names = 0.6 # Adjust label size
)

# Adding horizontal lines for drought classification thresholds
abline(h = -2.0, col = "darkred", lty = 2, lwd = 1.5)   # Extreme Drought
abline(h = -1.5, col = "red", lty = 2, lwd = 1.5)       # Severe Drought
abline(h = -1.0, col = "orange", lty = 2, lwd = 1.5)    # Moderate Drought
abline(h = 1.0, col = "green", lty = 2, lwd = 1.5)      # Above Normal

# Adding a legend
# legend("topright", legend = c("Extreme Drought (SDI ≤ -2)", "Severe Drought (SDI ≤ -1.5)", 
#                               "Moderate Drought (SDI ≤ -1)", "Above Normal (SDI ≥ 1)"),
#        col = c("darkred", "red", "orange", "green"), lty = 2, lwd = 1.5, cex = 0.8)
# 

# reduce the legend size
# legend(
#   "topright", # Position of the legend
#   inset = 0.02, # Slightly inset the legend
#   legend = c("Extreme Drought (SDI ≤ -2)", "Severe Drought (SDI ≤ -1.5)", 
#              "Moderate Drought (SDI ≤ -1)", "Above Normal (SDI ≥ 1)"),
#   col = c("darkred", "red", "orange", "green"), 
#   lty = 2, 
#   lwd = 1.5, 
#   cex = 0.5, # Smaller text size for the legend
#   bg = "white" # Optional: Adds a background to the legend
# )

# Reduce font size and place the kedend outside the graph
# Plot the bar chart
# barplot(
#   height = monthly_streamflow_data$Streamflow_drought_index_1m,
#   names.arg = monthly_streamflow_data$year_month,
#   col = ifelse(monthly_streamflow_data$Streamflow_drought_index_1m >= 0, "blue", "red"),
#   xlab = 'Date',
#   ylab = 'Stream flow drought Index (SDI)',
#   main = 'Streamflow drought Index Okavango_at_Mohembo',
#   las = 2, # Rotate x-axis labels for better readability
#   cex.names = 0.6, # Adjust label size
#   cex.main = 0.9 # Reduce title font size
#)

# Adding a legend outside the plot
legend(
  "topright", # Position relative to the graph
  inset = c(-0.03, 1.4), # Move outside the plot area
  legend = c("Extreme Drought (SDI ≤ -2)", "Severe Drought (SDI ≤ -1.5)", 
             "Moderate Drought (SDI ≤ -1)", "Above Normal (SDI ≥ 1)"),
  col = c("darkred", "red", "orange", "green"), 
  lty = 2, 
  lwd = 1.5, 
  cex = 0.7, # Smaller legend text
  xpd = TRUE, # Allow drawing outside plot area
  bg = "white" # Optional: Add background to the legend
)


















