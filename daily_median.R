library(ggplot2)
library(gtsummary)
library(tidyverse)
library(lubridate)
library(readxl)
library(writexl)
library(sjmisc)
library(flextable)
library(data.table)
library(plotly)
library(readr)
library(stringr)

About_the_household <- read_xlsx("About_the_household.xlsx", guess_max = 20000)

trend_df_lga = data.frame(c("Ibeju-Lekki", "Alimosho", "Badagry", "Somolu", "Lagos Mainland", "Agege", "Surulere", "Oshodi-Isolo", "Lagos Island", "Mushin", "Ajeromi", "Kosofe", "Amuwo odofin", "Epe", "Ikeja", "Ikorodu", "Apapa", "Ojo", "Eti-Osa", "Ifako-Ijaiye"))

# naming the columns
colnames(trend_df_lga)<-c("lga_name")

for (i in 1:max(About_the_household$`Mapping Day`)) {
  trend_df_lga[[paste0("day_",i)]] <- NA
}

for (j in 1:nrow(trend_df_lga)) {
  for(x in 2:ncol(trend_df_lga)) {
    for (i in 1:max(About_the_household$`Mapping Day`)){
       output <- About_the_household %>%
        dplyr::filter((`Mapping Day` == i) & (lga_name == trend_df_lga[j, "lga_name"])) %>%
        nrow()
    
       trend_df_lga[j, paste0("day_",i)] <- output
    }
  }
}

# trend_df_lga["overall_mean"] <- NA

# for (i in nrow(trend_df_lga)){
#   trend_df_lga[i, ncol(trend_df_lga)] <- sapply(trend_df_lga, mean)
# }

write_xlsx(trend_df_lga, "daily_trend_lga.xlsx")

EA_LGA <- About_the_household %>%
  dplyr::select(record_id, lga_name)

# Return all records and all variables
House_Mapping_raw <-
  REDCapR::redcap_report(
    redcap_uri = "https://live.cctris.org/redcap_v13.7.1/API/",
    token      = "02814B207A231775DB2EDE53D3F9E014",
    report_id  = 48,
    raw_or_label = "raw"
  )$data

House_Mapping_raw <- House_Mapping_raw %>%
  dplyr::select(record_id, enumeration_code)

House_Mapping_raw <- rename(House_Mapping_raw, enumeration_code_raw = enumeration_code)

EA_LGA <- EA_LGA %>%
  left_join(House_Mapping_raw, by = 'record_id')

EA_LGA_with_Codes <- EA_LGA %>%
  dplyr::filter(!is.na(enumeration_code_raw))

EA_LGA_with_Codes <- EA_LGA_with_Codes %>%
  group_by(enumeration_code_raw) %>%
  dplyr::filter(row_number()==1)

write_xlsx(EA_LGA_with_Codes, "EA_LGA_with_Codes.xlsx")