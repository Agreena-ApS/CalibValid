# Set the working directory to the appropriate location
setwd("/Users/marcospaulopedrosaalves/Documents/Git/CalibValid")

# Specify the folder where plots will be saved
plots_path <- "plots"

# ======================
# Soil char. plots
# ======================
library(ggpubr)
library(ggplot2)

# make a table with all soil types in the study
soiltypes <- function(x, type = "class") {
  env <-
    environmental_variables(x$Latitude, x$Longitude, x$Sampling_depth_increment)
  if (type == "class") {
    soil <- env$SoilType[1]
  } else {
    soil <- env$ParticleSizeClay[1]
  }
  return(soil)
}

class <- apply(calib_output$data_out, 1, soiltypes, type = "class")
clay <- apply(calib_output$data_out, 1, soiltypes, type = "Clay")

calib_output$data_out$Class <- class
calib_output$data_out$Clay <- clay

# Counts to report
counts <- aggregate(Publication_ID ~ Class, data = calib_output$data_out, FUN = function(x) length(unique(x)))

# Generate a frequency table of the names
name_counts <- table(calib_output$data_out$Class)

# Convert the frequency table to a data frame

# Define the custom factor levels
custom_levels <- c("CL", "L", "LSD", "SD", "SDCL", "SDL", "SC", "SCL", "SL")

# Replace the original values in the Class variable with custom factor levels
calib_output$data_out$Class <- factor(calib_output$data_out$Class)
levels(calib_output$data_out$Class) <- custom_levels

# p1 <- ggplot(df2, aes(x = class, y = Freq, fill = "Count"),) +
#   geom_bar(stat = "identity", width = 0.5) +
#   labs(x = "Soil class", y = "Field count") +
#   scale_fill_manual(values = "#365cbd") +
#   theme(legend.position = "none",
#         axis.title.x = element_text(margin = margin(t = 15)))
p1 <- ggplot(calib_output$data_out, aes(x = Class, fill = factor(Publication_ID))) +
  geom_bar() +
  labs(x = "Class", y = "Count", fill = "Publication ID") +
  scale_fill_discrete(name = "Publication ID") +
  theme(legend.position = "none",
        axis.title.x = element_text(margin = margin(t = 15)))+
  guides(fill = "none")

p2 <-
  ggplot(calib_output$data_out, aes(x = clay, fill = factor(Publication_ID))) +
  geom_histogram() +
  labs(x = "% of clay", y = "") +
  scale_fill_discrete(name = "Publication ID") +
  theme(legend.position = "none",
        axis.title.x = element_text(margin = margin(t = 15)))

figure <- ggarrange(p1,
                    p2,
                    labels = c("A", "B"),
                    ncol = 2,
                    nrow = 1)

span_clay <- max(clay) - min(clay)
ggsave(
  filename = paste0("Soil_charact.jpg"),
  plot = figure,
  width = 7,
  height = 3,
  path = plots_path
)


# ======================
# Weather class
# ======================

class <- calib_output$data_out$Climate_zones_IPCC
# Counts to report
counts <- aggregate(Publication_ID ~ Climate_zones_IPCC, data = calib_output$data_out, FUN = function(x) length(unique(x)))
writexl::write_xlsx(counts, "counts_weather.xlsx")
p <- ggplot(calib_output$data_out, aes(x = Climate_zones_IPCC, fill = factor(Publication_ID))) +
  geom_bar() +
  labs(x = "Class", y = "Count", fill = "Publication ID") +
  scale_fill_discrete(name = "Publication ID") +
  theme(legend.position = "none",
        axis.title.x = element_text(margin = margin(t = 15)))+
  guides(fill = "none")

ggsave(filename = "weather.jpg", plot = p, width = 7, height = 3, path = plots_path)
