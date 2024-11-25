rm(list = ls())
library(readxl)
library(dplyr)
library(lubridate)
library(tidyr)
library(ggplot2)

#load the input files
infile <- read_excel("data/input/WEAP/input/Model_damvolumes/Dam_volumes.xlsx", sheet = 'Dam_volume (Cubic meter)')

# Convert to long format
infile_long <- infile %>%
  pivot_longer(
    cols = -Date, # All columns except 'Date'
    names_to = "Dam",
    values_to = "Storage"
  )
infile_long


# Convert daily data to monthly mean
monthly_reservoir_data <- infile_long %>%
  mutate(year_month = floor_date(Date, "month")) %>%  # Extract month
  group_by(year_month, Dam) %>%                 # Group by month and dam type
  summarise(storage = mean(Storage), .groups = "drop")  # Calculate mean


# Calculate SRSI
SRSI<- monthly_reservoir_data %>%
  group_by(Dam) %>%
  mutate(
    mean_storage = mean(storage, na.rm = TRUE),
    sd_storage = sd(storage, na.rm = TRUE),
    SRSI = (storage - mean_storage) / sd_storage
  )
SRSI


# # Plot SRSI for 1 dam
# gaborone_data <- SRSI %>% filter(Dam == "Gaborone_dam")
# 
# # Plot SRSI over time for Gaborone_dam
# ggplot(gaborone_data, aes(x = year_month, y = SRSI)) +
#   geom_line(color = "blue", size = 1) +
#   #geom_point(color = "red", size = 2) +
#   labs(
#     title = "Standardised Reservoir Supply index for Gaborone Dam",
#     x = "a",
#     y = "SRSI"
#   ) +
#   theme_minimal() +
#   theme(
#     plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
#     axis.text = element_text(size = 10),
#     axis.title = element_text(size = 12)
#   )
# 
# 

# SPI Classification thresholds
SRSI_levels <- data.frame(
  Category = c("Extreme Drought", "Severe Drought", "Moderate Drought", 
               "Near Normal", "Moderately Wet", "Very Wet", "Extremely Wet"),
  Threshold = c(-2, -1.5, -1, 0, 1, 1.5, 2)
)

# Plot the bar graph
ggplot(gaborone_data, aes(x = year_month, y = SRSI)) +
  geom_bar(stat = "identity", fill = "skyblue", alpha = 0.8) +  # Bar graph
  geom_hline(data = SRSI_levels, aes(yintercept = Threshold, color = Category), 
             linetype = "dashed", size = 0.7) +  # SRSI Classification Lines
  scale_color_manual(
    values = c("red", "blue", "yellow", "green", "lightblue", "brown", "darkblue"),
    guide = guide_legend(title = "SRSI Classification")
  ) +
  labs(
    title = "SRSI for Gaborone Dam ",
    x = "Date",
    y = "SRSI"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    axis.text = element_text(size = 8),
    axis.title = element_text(size = 9),
    legend.position = "right"
  )
