# CalibValid

This script performs calibration using the custom package CalibValidRothC. The script also sets the working 
directory and specifies the folder where plots and .xlsx files will be saved.

## Prerequisites
Before running this script, make sure you have the following:

Required libraries: 
* dplyr
* [CalibValidRothC](https://github.com/Agreena-ApS/AgreenaRothC2) 
* googlesheets4 
* logger

## Output
The script performs calibration and produces the following outputs:


* Calibration results: calib_output_warm_tmp_moist.rds
* Summary statistics: summary_stats_warm_tmp_moist.xlsx
* PMU data: PMU_warm_tmp_moist.xlsx
* Solution data: solution_warm_tmp_moist.xlsx
