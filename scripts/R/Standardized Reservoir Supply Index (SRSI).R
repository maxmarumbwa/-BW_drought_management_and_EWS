rm(list = ls())
library(readxl)
library(dplyr)
library(lubridate)


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
  mutate(Month = floor_date(Date, "month")) %>%  # Extract month
  group_by(Month, dam_type) %>%                 # Group by month and dam type
  summarise(Storage = mean(storage), .groups = "drop")  # Calculate mean

# Convert daily data to monthly totals
monthly_resevoir_data <- infile_long %>%
  group_by(Dam) %>%
  mutate(year_month = format(Date, "%Y-%m")) %>%
  group_by(year_month) %>%
  summarise(Storage = sum(Storage))
monthly_resevoir_data

# Calculate SRSI
srsic<- infile_long %>%
  group_by(Dam) %>%
  mutate(
    mean_value = mean(value, na.rm = TRUE),
    sd_value = sd(value, na.rm = TRUE),
    SRSI = (value - mean_value) / sd_value
  )

# View results
print(srsic)






library(dplyr)

# Sample long-format data
df_long <- data.frame(
  Date = as.Date(rep(seq(as.Date("2011-01-01"), by = "days", length.out = 5), 4)),
  dam_type = rep(c("_dam", "hog_dam", "ne_dam", "go_dam"), each = 5),
  value = c(
    18270264, 18500000, 18500000, 18436614, 18500000,
    394279296, 397609824, 399451424, 399368736, 400000000,
    57041584, 57007356, 57653476, 57661516, 58125388,
    108736024, 108812304, 109315200, 109145720, 109141968
  )
)

# Calculate SRSI
srsi <- df_long %>%
  group_by(dam_type) %>%
  mutate(
    mean_value = mean(value, na.rm = TRUE),
    sd_value = sd(value, na.rm = TRUE),
    SRSI = (value - mean_value) / sd_value
  )

# View results
print(srsi)
