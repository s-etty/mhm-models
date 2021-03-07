library(survival)
library(survminer)
library(dplyr)

lots <- lots %>%
  mutate(month = month(collection_timestamp))

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

f1 <- survfit(Surv(time_to_close, status) ~ date, data = main_lot_closed)
cox_model <- coxph(Surv(time_to_close, status) ~ weekday + date + month, data = main_lot_closed)

saturdays_f1 <- survfit(Surv(time_to_close, status) ~ 1, data = saturdays)

ggsurvplot(f1)
ggsurvplot(saturdays_f1)
ggforest(cox_model)
cox_model

main_lot_closed_no_zero <- main_lot_closed %>%
  filter(time_to_close != 0)
test_regression <- survreg(Surv(time_to_close, status) ~ weekday + date + month,
                           data = main_lot_closed_no_zero)
test_regression 

test_df <- tibble(weekday = "Sat", date = ymd("2021-03-06"), month = 3)

pred_close <- predict(test_regression, newdata = test_df, type = "quantile",
        p = c(0.05, 0.1, 0.5, 0.9, 0.95))

ymd_hm("2021-01-01 7:00") + minutes(as.integer(pred_close))
