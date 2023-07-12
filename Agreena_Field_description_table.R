# Prepare data for submission


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

calib_output$data_out <- data_source
# Overriding Soil texture with information from SoilGrids 
calib_output$data_out$Soil_texture <- apply(calib_output$data_out, 1, soiltypes, type = "class")
calib_output$data_out$Clay_soilgrids <- apply(calib_output$data_out, 1, soiltypes, type = "clay")
report_table <- calib_output$data_out
report_table <- report_table %>% select(
  Publication_ID,
  Field_ID,
  Latitude,
  Longitude,
  Climate_zones_IPCC,
  Study_period_start,
  Study_period_end,
  Soil_texture,
  Clay_soilgrids,
  Bulk_Density,
  Sampling_depth_increment,
  Crops_Rotations,
  Residue_Management,
  Cover_crop_regime,
  Tillage_regime,
  agreena_fert,
  SOC_Start_Original_Value,
  SOC_End_Original_Value,
  Measument_technique,
  SOC_Original_Unit,
  Standardized_Unit,
  SOC_Start_Converted,
  SOC_End_Converted,
) %>% 
  rename(
    "Publication ID"= Publication_ID,
    "Field ID" = Field_ID,
    "Latitude" = Latitude,
    "Longitude" = Longitude,
    "Climate zones (IPCC)" = Climate_zones_IPCC,
    "Study period start" = Study_period_start,
    "Study period end" = Study_period_end,
    "Soil texture (USAD)" = Soil_texture,
    "Clay (SoilGrids)" = Clay_soilgrids,
    "Bulk Density (g/cm3)" = Bulk_Density,
    "Sampling depth increment" = Sampling_depth_increment,
    "Crops Rotations" = Crops_Rotations,
    "Residue Management" = Residue_Management,
    "Cover crop regime" = Cover_crop_regime,
    "Tillage regime" = Tillage_regime,
    "Agreena fertilizer type" = agreena_fert,
    "SOC start (original)" =  SOC_Start_Original_Value,
    "SOC end (original)" =  SOC_End_Original_Value,
    "Measument technique (description)" = Measument_technique,
    "Orignal SOC unit" = SOC_Original_Unit,
    "Standardized unit" = Standardized_Unit,
    "SOC start (converted tC/ha)" = SOC_Start_Converted,
    "SOC end (converted tC/ha)" = SOC_End_Converted
  )


conversion_table <- c(`%` = "Bulk Density * sampling depth * SOC Orignal", 
                      `mgC/g` = "(Bulk Density * sampling depth * SOC Orignal)/10", 
                      `t C/ha` = "1 * SOC Orignal", 
                      `g C/kg` = "(Bulk Density * sampling depth * SOC Orignal)/10", 
                      `g C/m^2` = "1/100 * SOC Orignal", 
                      `kg/ha` = "1/1000 * SOC Orignal", 
                      `kg/layer` = "10000/100 * SOC Orignal")

report_table$`Conversion formula` <- conversion_table[report_table$`Standardized unit`]

writexl::write_xlsx(report_table, "Agreena_Field_description_table_v2_050723_new.xlsx")

# papers table

papers <- readxl::read_xlsx("/Users/marcospaulopedrosaalves/Downloads/Data calib _ Valid (4).xlsx", sheet = 2)
selectec_papers <- papers[papers$`Publication ID` %in% unique(report_table$`Publication ID`),]
writexl::write_xlsx(selectec_papers, "papers.xlsx")

