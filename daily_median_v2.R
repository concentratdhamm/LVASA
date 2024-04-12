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

About_the_household <- read_xlsx("About_the_household_v2.xlsx", guess_max = 20000)

selected_EA <- read_xlsx("selected_Lagos_EA_listing.xlsx", guess_max = 20000)

# trend_df_lga = data.frame(c("Ibeju-Lekki", "Alimosho", "Badagry", "Somolu", "Lagos Mainland", "Agege", "Surulere", "Oshodi-Isolo", "Lagos Island", "Mushin", "Ajeromi", "Kosofe", "Amuwo odofin", "Epe", "Ikeja", "Ikorodu", "Apapa", "Ojo", "Eti-Osa", "Ifako-Ijaiye"))

# # naming the columns
# colnames(trend_df_lga)<-c("lga_name")
# 
# for (i in 1:max(About_the_household$`Mapping Day`)) {
#   trend_df_lga[[paste0("day_",i)]] <- NA
# }
# 
# for (j in 1:nrow(trend_df_lga)) {
#   for(x in 2:ncol(trend_df_lga)) {
#     for (i in 1:max(About_the_household$`Mapping Day`)){
#        output <- About_the_household %>%
#         dplyr::filter((`Mapping Day` == i) & (lga_name == trend_df_lga[j, "lga_name"])) %>%
#         nrow()
#     
#        trend_df_lga[j, paste0("day_",i)] <- output
#     }
#   }
# }
# 
# write_xlsx(trend_df_lga, "daily_trend_lga.xlsx")

EA_LGA <- About_the_household %>%
  dplyr::select(lga_name, EA_Code_v2)

# # Return all records and all variables
# House_Mapping_raw <-
#   REDCapR::redcap_report(
#     redcap_uri = "https://live.cctris.org/redcap_v13.7.1/API/",
#     token      = "02814B207A231775DB2EDE53D3F9E014",
#     report_id  = 48,
#     raw_or_label = "raw"
#   )$data
# 
# House_Mapping_raw <- House_Mapping_raw %>%
#   dplyr::select(record_id, enumeration_code)
# 
# House_Mapping_raw <- rename(House_Mapping_raw, enumeration_code_raw = enumeration_code)
# 
# EA_LGA <- EA_LGA %>%
#   left_join(House_Mapping_raw, by = 'record_id')
# 
# EA_LGA_with_Codes <- EA_LGA %>%
#   dplyr::filter(!is.na(enumeration_code_raw))

EA_LGA <- EA_LGA %>%
  # arrange(lga_name) %>%
  group_by(lga_name, EA_Code_v2) %>%
  dplyr::filter(row_number()==1)

EA_LGA['Total No of Household'] <- NA

temp_EA <- NA

temp_LGA <- NA

for (i in 1:nrow(EA_LGA)){
  temp_EA <- as.numeric(EA_LGA[i, "EA_Code_v2"])
  temp_LGA <- as.character(EA_LGA[i, "lga_name"])
  
  EA_LGA[i, "Total No of Household"] <- About_the_household %>%
    dplyr::filter((temp_EA == About_the_household$EA_Code_v2) & (temp_LGA == About_the_household$lga_name)) %>%
    nrow()
}

write_xlsx(EA_LGA, "EA_LGA_with_Codes.xlsx")

EA_LGA$`EA-code` = EA_LGA$EA_Code_v2

for (i in 1:nrow(EA_LGA)){
  EA_LGA[i, 'lga_name'] <- toupper(EA_LGA[i, 'lga_name'])
}

for (i in 1:nrow(EA_LGA)){
  EA_LGA[i, 'lga_name'] <-
  case_when(
    (EA_LGA[i, 'lga_name'] == "AGEGE") ~ "AGEGE"
    ,(EA_LGA[i, 'lga_name'] == "ALIMOSHO") ~ "ALIMOSHO"
    ,(EA_LGA[i, 'lga_name'] == "AMUWO ODOFIN") ~ "AMUWO ODOFIN"
    ,(EA_LGA[i, 'lga_name'] == "APAPA") ~ "APAPA"
    ,(EA_LGA[i, 'lga_name'] == "EPE") ~ "EPE"
    ,(EA_LGA[i, 'lga_name'] == "IKEJA") ~ "IKEJA"
    ,(EA_LGA[i, 'lga_name'] == "IKORODU") ~ "IKORODU"
    ,(EA_LGA[i, 'lga_name'] == "KOSOFE") ~ "KOSOFE"
    ,(EA_LGA[i, 'lga_name'] == "LAGOS ISLAND") ~ "LAGOS ISLAND"
    ,(EA_LGA[i, 'lga_name'] == "LAGOS MAINLAND") ~ "LAGOS MAINLAND"
    ,(EA_LGA[i, 'lga_name'] == "OJO") ~ "OJO"
    ,(EA_LGA[i, 'lga_name'] == "SURULERE") ~ "SURULERE"
    ,(EA_LGA[i, 'lga_name'] == "BADAGRY") ~ "BADAGRY"
    ,(EA_LGA[i, 'lga_name'] == "MUSHIN") ~ "MUSHIN"
    ,(EA_LGA[i, 'lga_name'] == "AJEROMI")  ~ "AJEROMI IFELODUN"
    ,(EA_LGA[i, 'lga_name'] == "ETI-OSA")  ~ "ETI OSA"
    ,(EA_LGA[i, 'lga_name'] == "IBEJU-LEKKI")  ~ "IBEJU LEKKI"
    ,(EA_LGA[i, 'lga_name'] == "IFAKO-IJAIYE")  ~ "IFAKO IJAYE"
    ,(EA_LGA[i, 'lga_name'] == "OSHODI-ISOLO")  ~ "OSHODI ISOLO"
    ,(EA_LGA[i, 'lga_name'] == "SOMOLU")  ~ "SHOMOLU"
  )
}

selected_EA <- selected_EA %>%
  left_join(EA_LGA, by = c('Lga_name'='lga_name', 'EA-code'='EA-code'))

write_xlsx(selected_EA, "selected_EA_Done.xlsx")
