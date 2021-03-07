library(survival)
library(dplyr)

main_lot <- lots %>%
  filter(lot_name == "Main") %>%
  group_by(date) %>%
  filter(status == "Standby" | status == "Closed") %>%
  slice(1) %>%
  mutate(time_to_close = difftime(adjusted_timestamp,
                                  ymd_hm("2021-01-01 07:00", tz = "America/Los_Angeles"),
                                  units = "mins"),
         status = TRUE)

saturdays <- main_lot %>%
  filter(weekday == "Sat")

f1 <- survfit(Surv(time_to_close, status) ~ 1, data = main_lot)

saturdays_f1 <- survfit(Surv(time_to_close, status) ~ 1, data = saturdays)

plot(f1)
plot(saturdays_f1)
