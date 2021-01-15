library(readr)
library(dplyr)

#column names for the log.txt
columns <- c("collection_timestamp", "lot_name", "status",
             "degrees_f", "wind", "short_forecast")
#the url to the log.txt file
fp <- "https://snowpackmap.com/super_duper_top_secret_thingy_seriously_dont_look"

#read the log from the URL, delimited by |
#then assign colnames
lifts <- read_delim(file = fp, delim = "|", col_names = F)
colnames(lifts) <- columns

