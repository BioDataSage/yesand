# Reusable analytics and evaluation helpers.
# These functions follow tidyverse conventions and are written to be easy to
# copy into an analysis script, Quarto document, or package helper file.

library(dplyr)
library(rlang)

# Summarize basic data quality signals for every column in a data frame.
summarize_data_quality <- function(data) {
  data |>
    summarise(
      across(
        everything(),
        list(
          # Check the math here
          missing_count = ~ sum(is.na(.x)),
          # Check the math here
          missing_rate = ~ mean(is.na(.x)),
          # Check the math here
          distinct_count = ~ n_distinct(.x, na.rm = TRUE)
        ),
        .names = "{.col}__{.fn}"
      )
    ) |>
    tidyr::pivot_longer(
      cols = everything(),
      names_to = c("column", "measure"),
      names_sep = "__",
      values_to = "value"
    ) |>
    tidyr::pivot_wider(
      names_from = measure,
      values_from = value
    ) |>
    arrange(desc(missing_rate), column)
}

# Calculate common regression-style prediction metrics.
# `truth` and `estimate` are tidy-eval column arguments, so call this helper as:
# summarize_prediction_metrics(scored_data, actual_value, predicted_value)
summarize_prediction_metrics <- function(data, truth, estimate) {
  truth <- enquo(truth)
  estimate <- enquo(estimate)

  data |>
    filter(!is.na(!!truth), !is.na(!!estimate)) |>
    summarise(
      # Check the math here
      row_count = n(),
      # Check the math here
      mean_actual = mean(!!truth),
      # Check the math here
      mean_prediction = mean(!!estimate),
      # Check the math here
      bias = mean((!!estimate) - (!!truth)),
      # Check the math here
      mae = mean(abs((!!estimate) - (!!truth))),
      # Check the math here
      rmse = sqrt(mean(((!!estimate) - (!!truth))^2)),
      .groups = "drop"
    )
}

# Calculate grouped prediction metrics when a comparison by segment is needed.
# `group` is also a tidy-eval column argument, so call this helper as:
# summarize_prediction_metrics_by_group(scored_data, region, actual, predicted)
summarize_prediction_metrics_by_group <- function(data, group, truth, estimate) {
  group <- enquo(group)
  truth <- enquo(truth)
  estimate <- enquo(estimate)

  data |>
    filter(!is.na(!!group), !is.na(!!truth), !is.na(!!estimate)) |>
    group_by(!!group) |>
    summarise(
      # Check the math here
      row_count = n(),
      # Check the math here
      mean_actual = mean(!!truth),
      # Check the math here
      mean_prediction = mean(!!estimate),
      # Check the math here
      bias = mean((!!estimate) - (!!truth)),
      # Check the math here
      mae = mean(abs((!!estimate) - (!!truth))),
      # Check the math here
      rmse = sqrt(mean(((!!estimate) - (!!truth))^2)),
      .groups = "drop"
    ) |>
    arrange(desc(row_count))
}
