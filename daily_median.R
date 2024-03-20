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

trend_df_lga["overall_mean"] <- NA

# for (i in nrow(trend_df_lga)){
#   trend_df_lga[i, ncol(trend_df_lga)] <- sapply(trend_df_lga, mean)
# }

write_xlsx(trend_df_lga, "daily_trend_lga.xlsx")
