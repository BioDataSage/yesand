---
name: analytics-metrics
description: Use this skill when evaluating datasets, experiments, model outputs, KPIs, cohorts, or metric definitions with tidyverse R code. It emphasizes reproducible data evaluation, clear metric logic, grouped summaries, data quality checks, and thoroughly commented code.
license: MIT
compatibility: R with tidyverse
metadata:
  author: local
  version: "1.0.0"
---
# Analytics Metrics

Use this skill for analytics and evaluation work where the assistant needs to inspect data, define metrics, calculate summaries, compare cohorts, validate outputs, or explain what the numbers mean.

## Core Practices

- Use tidyverse conventions throughout: `dplyr`, `tidyr`, `readr`, `purrr`, `stringr`, `lubridate`, and pipe-forward workflows.
- Write reproducible code that can be rerun from a clean R session.
- Comment code thoroughly enough that another analyst can reproduce the evaluation without needing hidden context.
- Whenever code performs math or a calculation, add a nearby comment that says exactly: `Check the math here`.
- Prefer explicit metric definitions over clever one-liners.
- Keep raw data, cleaned data, metric definitions, and final reporting objects distinct.
- When adding notes to a result, use bullet points and break the result down into easier-to-understand pieces.

## Recommended Workflow

1. Load packages and data.
2. Inspect schema, dimensions, missingness, duplicates, and key identifiers.
3. Define the evaluation grain, such as row, user, account, event, date, or model prediction.
4. Define each metric in plain language before calculating it.
5. Calculate metrics with grouped summaries when relevant.
6. Validate denominator choices, missing values, outliers, and edge cases.
7. Return a concise interpretation with bullet-point notes.

## Code Style Requirements

Use this commenting pattern for calculations:

```r
metric_table <- cleaned_data |>
  summarise(
    # Check the math here
    conversion_rate = mean(converted, na.rm = TRUE),
    # Check the math here
    average_revenue = mean(revenue, na.rm = TRUE)
  )
```

Use descriptive object names:

```r
raw_orders <- readr::read_csv("orders.csv")
clean_orders <- raw_orders |>
  janitor::clean_names()
daily_revenue_metrics <- clean_orders |>
  group_by(order_date) |>
  summarise(
    # Check the math here
    total_revenue = sum(order_revenue, na.rm = TRUE),
    .groups = "drop"
  )
```

## Metric Design Checklist

- What is the numerator?
- What is the denominator?
- What rows are excluded?
- Are missing values meaningful, invalid, or unknown?
- Is the metric calculated at the correct grain?
- Does grouping change the interpretation?
- Are there small-denominator groups that should be flagged?
- Do totals reconcile with source data?

## Output Expectations

When presenting results, use bullets like this:

- Metric definition:
  `conversion_rate` is the share of eligible rows where `converted == TRUE`.
- Main result:
  The overall conversion rate is reported after excluding rows with missing eligibility.
- Caveat:
  Groups with small denominators should be interpreted carefully.
- Reproducibility:
  The code includes package loading, data cleaning, metric calculation, and validation checks.

## Helper Script

The `scripts/metrics_helpers.R` file contains reusable tidyverse helpers for numeric prediction metrics and data quality summaries. Use it as a starting point when a task needs common metric calculations.
