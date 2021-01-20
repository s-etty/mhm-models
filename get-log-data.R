library(readr)
library(tidyr)
library(dplyr)
library(stringr)

#column names for the log.txt
lots_columns <- c("collection_timestamp", "lot_name", "status",
             "degrees_f", "wind", "short_forecast")
#the url to the log.txt file
fp <- "https://snowpackmap.com/super_duper_top_secret_thingy_seriously_dont_look"

#read the log from the URL, delimited by |
#then assign colnames
lots <- read_delim(file = fp, delim = "|", col_names = lots_columns,
                   col_types = cols(
                     collection_timestamp = col_datetime(format = "%d/%m/%Y %H:%M:%S"),
                     lot_name = col_character(),
                     status = col_character(),
                     degrees_f = col_character(),
                     wind = col_character(),
                     short_forecast = col_character()
                   ))

#clean the data a bit
lots <- lots %>%
  mutate(across(where(is.character), str_trim),
         degrees_f = as.integer(degrees_f)) %>%
  separate(wind, into = c("wind_speed", "wind_units"), sep = " ") %>%
  mutate(wind_speed = as.integer(wind_speed))

