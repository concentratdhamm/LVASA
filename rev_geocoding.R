library(tidyverse)
library(tidygeocoder)
library(sf)
library(mapview)
library(readxl)
library(writexl)

# Return all records and all variables
Geolocation <-
  REDCapR::redcap_report(
    redcap_uri = "https://live.cctris.org/redcap_v13.7.1/API/",
    token      = "02814B207A231775DB2EDE53D3F9E014",
    report_id  = 41,
    raw_or_label = "label"
  )$data

drop_columns <- c('redcap_event_name')
Geolocation <- Geolocation %>%
  select(-one_of(drop_columns))

Geolocation <- Geolocation %>%
  add_column(Unique_location = 
               (Geolocation$geolocation_of_house_lat + Geolocation$geolocation_of_house_longi)
             , .after = "geolocation_of_house_longi")

Unique_Geo <- Geolocation %>%
  group_by(Unique_location) %>%
  dplyr::filter(row_number()==1)

geo_reverse_tbl <- Unique_Geo %>%
  
  # Pretend we don't have the address...
  # select(-address) %>%
  
  # Go from Lat/Lon to Address
  tidygeocoder::reverse_geocode(
    lat    = geolocation_of_house_lat,
    long   = geolocation_of_house_longi,
    method = "osm"
  )

write_xlsx(geo_reverse_tbl, "Geolocation_osm.xlsx")