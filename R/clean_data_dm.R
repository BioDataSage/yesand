# clean_data_dm.R
# Data cleaning script for squirrel_raw, park_raw, and stories_raw
# Decisions approved on 2026-08-24

library(tidyverse)
library(janitor)

# ── squirrel_raw ──────────────────────────────────────────────────────────────

squirrel_clean <- squirrel_raw |>

  # Rename all columns to snake_case
  clean_names() |>

  # Convert above-ground height to numeric; range values (encoding-corrupted)
  # become NA via coercion
  mutate(
    above_ground_height_in_feet = suppressWarnings(
      as.numeric(above_ground_height_in_feet)
    )
  )

# ── park_raw ──────────────────────────────────────────────────────────────────

park_clean <- park_raw |>

  # Rename all columns to snake_case
  clean_names() |>

  # Parse the date string to a proper Date type
  mutate(date = as.Date(date, format = "%m/%d/%y")) |>

  # Park conditions: strip quotes, extract core category before comma or dash,
  # preserve the original note in a companion column
  mutate(
    park_conditions_notes = if_else(
      str_detect(park_conditions, '[",]|-(?!\\d)'),
      str_replace_all(park_conditions, '"', '') |>
        str_remove("^[^,\\-]+") |>
        str_remove("^[,\\s\\-]+") |>
        str_trim() |>
        na_if(""),
      NA_character_
    ),
    park_conditions = str_replace_all(park_conditions, '"', '') |>
      str_extract("^[^,\\-]+") |>
      str_trim()
  ) |>

  # Litter: extract core category before the first comma; preserve notes
  mutate(
    litter_notes = if_else(
      str_detect(litter, ","),
      str_remove(litter, "^[^,]+,\\s*") |> str_trim(),
      NA_character_
    ),
    litter = str_extract(litter, "^[^,]+") |> str_trim()
  )

# ── stories_raw ───────────────────────────────────────────────────────────────

stories_clean <- stories_raw |>

  # Rename all columns to snake_case
  clean_names()

# ── Preview results ───────────────────────────────────────────────────────────

glimpse(squirrel_clean)
glimpse(park_clean)
glimpse(stories_clean)
