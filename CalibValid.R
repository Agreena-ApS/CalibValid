#==================
# Calibration
#==================

# Load required libraries
library(dplyr)                          # For data manipulation and summarization
library(CalibValidRothC)                # Custom package for calibration and validation
library(googlesheets4)                  # For reading data from Google Sheets
library(logger)
log_threshold(TRACE)

# Set the seed for reproducibility
set.seed(123)

# Set the working directory to the appropriate location
setwd("CalibValid")

# Specify the folder where plots will be saved
plots_path <- "plots"

# Set the option for calibration inputs directory (used to load fertlizer content, country yields and etc)
options(param_inputs = "data")

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
calib_output <- calibration(data_source, stopval = 1, maxeval = 50, lb = 0.8, ub = 1.2, print_nlopt = F)
calib_output <- calib_output1

names(calib_output$all_metrics)[8] <- "Climate_zones_IPCC"
weighted_mean <- function(x, n) {
  sum(x * n) / sum(n)
}

# Calculate mean bias for each combination of Publication_ID, Practice_Category, Climate_zones_IPCC, and CFGs
bias_pooled_study <- calib_output[["all_metrics"]] %>%
  group_by(Publication_ID, Practice_Category, Climate_zones_IPCC, CFGs) %>%
  summarise(mean_bias = weighted_mean(bias, fold_test_size))

# Calculate mean bias for each combination of Practice_Category, Climate_zones_IPCC, and CFGs
bias_pooled_comb <- calib_output[["all_metrics"]] %>%
  group_by(Practice_Category, Climate_zones_IPCC, CFGs) %>%
  summarise(mean_bias = weighted_mean(bias, fold_test_size))

# Calculate mean bias for all data points
bias_pooled_all <- calib_output[["all_metrics"]] %>%
  ungroup() %>%
  summarise(mean_bias = weighted_mean(bias, fold_test_size))

# Calculate mean RMSE for each combination of Publication_ID, Practice_Category, Climate_zones_IPCC, and CFGs
rmse_pooled_study <- calib_output[["all_metrics"]] %>%
  group_by(Publication_ID, Practice_Category, Climate_zones_IPCC, CFGs) %>%
  summarise(mean_rmse = weighted_mean(rmse, fold_test_size))

# Calculate mean RMSE for each combination of Practice_Category, Climate_zones_IPCC, and CFGs
rmse_pooled_comb <- calib_output[["all_metrics"]] %>%
  group_by(Practice_Category, Climate_zones_IPCC, CFGs) %>%
  summarise(mean_rmse = weighted_mean(rmse, fold_test_size))

# Calculate mean RMSE for all data points
rmse_pooled_all <- calib_output[["all_metrics"]] %>%
  ungroup() %>%
  summarise(mean_rmse = weighted_mean(rmse, fold_test_size))

# Calculate the number of studies used for each combination
studycount <- calib_output[["all_metrics"]] %>%
  group_by(Practice_Category, Climate_zones_IPCC, CFGs) %>%
  summarise(n_studies = n())

# Calculate PMU
PMU <- calculate_pmu(data_source)

# Calculate confidence intervals for calibration output data
Cis <- conf_int(calib_output[["data_out"]])

# Plot validation results and save the plots in the specified folder
plot_validt3(Cis, plots_path)

# Save the calibration output to a file with extension ".rds"
saveRDS(calib_output, "calib_output_warm_tmp_moist.rds")

# Producing summary table
summary_stats <- joined_stats(bias_pooled_comb, rmse_pooled_comb, studycount, Cis, PMU, c("Practice_Category", "Climate_zones_IPCC", "CFGs"))
writexl::write_xlsx(summary_stats, "summary_stats_warm_tmp_moist.xlsx")
writexl::write_xlsx(PMU, "PMU_warm_tmp_moist.xlsx")
writexl::write_xlsx(as.data.frame(calib_output$solution), "solution_warm_tmp_moist.xlsx")

# loading calib_out to memory
calib_output <- readRDS("calib_output_0.8_1.2.rds")
calib_output$data_out <- calib_out$data_out %>% filter(Publication_ID != "143")
