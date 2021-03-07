library(survival)
library(survminer)
library(dplyr)

main_lot_closed <- lots %>%
  filter(lot_name == "Main") %>%
  group_by(date) %>%
  filter(status == "Standby" | status == "Closed") %>%
  slice(1) %>%
  mutate(time_to_close = difftime(adjusted_timestamp,
                                  ymd_hm("2021-01-01 07:00", tz = "America/Los_Angeles"),
                                  units = "mins"),
         status = TRUE,
         weekday = as.factor(weekday))

main_lot_open <- lots %>%
  filter(lot_name == "Main") %>%
  group_by(date) %>%
  filter(n_distinct(status) == 1) %>%
  arrange(desc(collection_timestamp)) %>%
  slice(1) %>%
  mutate(time_to_close = difftime(adjusted_timestamp,
                                  ymd_hm("2021-01-01 07:00", tz = "America/Los_Angeles"),
                                  units = "mins"),
         status = FALSE)

main_lot <- bind_rows(main_lot_closed, main_lot_open) %>%
  mutate(weekday = as.factor(weekday)) %>%
  arrange(collection_timestamp)

saturdays <- main_lot %>%
  filter(weekday == "Sat")

f1 <- survfit(Surv(time_to_close, status) ~ 1, data = main_lot)
cox_model <- coxph(Surv(time_to_close, status) ~ weekday, data = main_lot_closed)

saturdays_f1 <- survfit(Surv(time_to_close, status) ~ 1, data = saturdays)

ggsurvplot(f1)
ggsurvplot(saturdays_f1)
ggforest(cox_model)
cox_model
