library(readxl)
library(SPEI)
library(dplyr)

#load the input files
#infile <- read_excel("data/input/WEAP/input/Model_streamflow/Boteti_river_at_Samedupi.xlsx", 
#          sheet = "Sheet2")
#colnames(infile) <- c("Date","Streamflow")                                  
                                      
#infile<- read_excel("data/input/WEAP/input/Model_streamflow/Limpopo_at_Buffels.xlsx", 
#                               sheet = "Sheet2")
#colnames(infile) <- c("Date","Streamflow")   
# # error sum last column
#infile<- read_excel("data/input/WEAP/input/Model_streamflow/Limpopo_at_Seleka.xlsx",                                 sheet = "Sheet2", col_types = c("date","numeric"))
#  colnames(infile) <- c("Date","Streamflow")   
#infile<- read_excel("data/input/WEAP/input/Model_streamflow/Ntse_at_Ntse_weir.xlsx", 
#                                sheet = "Sheet2", col_types = c("date","numeric"))
#colnames(infile) <- c("Date","Streamflow")   
#infile<- read_excel("data/input/WEAP/input/Model_streamflow/Okavango_at_Mohembo.xlsx", 
#                                  sheet = "Sheet2", col_types = c("date","numeric"))
#colnames(infile) <- c("Date","Streamflow")   
#infile<- read_excel("data/input/WEAP/input/Model_streamflow/Tati_at_Tati_weir.xlsx", 
#                               sheet = "Sheet2", col_types = c("date","numeric"))
#colnames(infile) <- c("Date","Streamflow")   
infile<- read_excel("data/input/WEAP/input/Model_streamflow/Thamalakane_at_Maun_bridge.xlsx", 
                                         sheet = "Sheet2", col_types = c("date","numeric"))
colnames(infile) <- c("Date","Streamflow")   

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
write.csv(monthly_streamflow_data, "output/csv/Stream_flow_drought_Index_Thamalakane_at_Maun_bridge.csv", row.names = FALSE)

# # Plot the SDI values over time
plot(monthly_streamflow_data$date, monthly_streamflow_data$Streamflow_drought_index_6m, type = 'l', col = 'blue',
     xlab = 'Date', ylab = 'SDI', main = 'Streamflow drought Index Thamalakane_at_Maun_bridge')


