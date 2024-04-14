library(tidyverse)
library(tidygeocoder)
library(sf)
library(mapview)
library(readxl)
library(writexl)

House_Mapping <- read_xlsx("House_Mapping_v2.xlsx", guess_max = 20000)

House_Mapping <- House_Mapping %>%
  dplyr::filter(Unique_location == "Yes")

geo_reverse_tbl <- House_Mapping %>%
  
  # Pretend we don't have the address...
  # select(-address) %>%
  
  # Go from Lat/Lon to Address
  tidygeocoder::reverse_geocode(
    lat    = geolocation_of_house_lat,
    long   = geolocation_of_house_longi,
    method = "osm"
  )

write_xlsx(geo_reverse_tbl, "Geolocation_osm.xlsx")