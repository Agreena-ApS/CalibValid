#==================
# Calibration
#==================

# Load required libraries
library(dplyr)                          # For data manipulation and summarization
library(CalibValidRothC)                # Custom package for calibration and validation
library(googlesheets4)                  # For reading data from Google Sheets

# Set the seed for reproducibility
set.seed(123)

# Set the working directory to the appropriate location
setwd("/Users/marcospaulopedrosaalves/Documents/Git/CalibValid")

# Specify the folder where plots will be saved
plots_path <- "plots"

# Set the option for calibration inputs directory (used to load fertlizer content, country yields and etc)
options(calib_inputs = "data")

# Read data from a Google Sheets
data_source <- read_sheet("1GJFvOWphkvXGKi-8h-IV4EXviaxa8hCcPembe-XdGSU", range = "A4:AP664", col_names = F)
names <- read_sheet("1GJFvOWphkvXGKi-8h-IV4EXviaxa8hCcPembe-XdGSU", range = "A1:AP1", col_names = F)

# Assign column names to the data_source based on the content of the first row
colnames(data_source) <- names

# Expand the data set, adding additional columns and rows for calibration
data_source <- expand_data_set(data_source)

# Check for any problem rows in the data_source
problem_rows <- test_data_source(data_source)

# Perform calibration using the specified parameters
calib_output <- calibration(data_source2, stopval = 1, maxeval = 1, lb = 0.8, ub = 1.2)

# Calculate mean bias for each combination of Publication_ID, Practice_Category, climate_zone, and CFGs
bias_pooled_study <- calib_output[["all_metrics"]] %>%
  group_by(Publication_ID, Practice_Category, climate_zone, CFGs) %>%
  summarise(mean_bias = mean(bias))

# Calculate mean bias for each combination of Practice_Category, climate_zone, and CFGs
bias_pooled_comb <- calib_output[["all_metrics"]] %>%
  group_by(Practice_Category, climate_zone, CFGs) %>%
  summarise(mean_bias = mean(bias))

# Calculate mean bias for all data points
bias_pooled_all <- calib_output[["all_metrics"]] %>%
  ungroup() %>%
  summarise(mean_bias = mean(bias))

# Calculate mean RMSE for each combination of Publication_ID, Practice_Category, climate_zone, and CFGs
rmse_pooled_study <- calib_output[["all_metrics"]] %>%
  group_by(Publication_ID, Practice_Category, climate_zone, CFGs) %>%
  summarise(mean_rmse = mean(rmse))

# Calculate mean RMSE for each combination of Practice_Category, climate_zone, and CFGs
rmse_pooled_comb <- calib_output[["all_metrics"]] %>%
  group_by(Practice_Category, climate_zone, CFGs) %>%
  summarise(mean_rmse = mean(rmse))

# Calculate mean RMSE for all data points
rmse_pooled_all <- calib_output[["all_metrics"]] %>%
  ungroup() %>%
  summarise(mean_rmse = mean(rmse))

# Calculate confidence intervals for calibration output data
Cis <- conf_int(calib_output[["data_out"]])

# Plot validation results and save the plots in the specified folder
plot_validt(Cis, plots_path)

# Save the calibration output to a file with extension ".rds"
saveRDS(calib_output, "calib_output.rds")
