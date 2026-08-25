library(tidyverse)
library(janitor)

# ── Load raw data ──────────────────────────────────────────────────────────────
park_raw     <- read_csv("park-data.csv",     show_col_types = FALSE)
squirrel_raw <- read_csv("squirrel-data.csv", show_col_types = FALSE)
stories_raw  <- read_csv("stories.csv",       show_col_types = FALSE)


# ── park-data ──────────────────────────────────────────────────────────────────
park_clean <- park_raw |>
  clean_names() |>
  rename(
    total_time_minutes = total_time_in_minutes_if_available,
    temp_weather       = temperature_weather,
    n_squirrels        = number_of_squirrels,
    squirrel_sighters  = squirrel_sighter_s,
    n_sighters         = number_of_sighters
  ) |>
  mutate(
    # Parse date from character
    date = as.Date(date, format = "%m/%d/%y"),
    # Normalise Park Conditions to first word only
    park_conditions = str_extract(park_conditions, "^[A-Za-z]+")
  )


# ── squirrel-data ──────────────────────────────────────────────────────────────
squirrel_clean <- squirrel_raw |>
  clean_names() |>
  rename(
    highlights_fur_color = highlights_in_fur_color,
    above_ground_ft      = above_ground_height_in_feet,
    specific_location    = specific_location,
    other_notes          = other_notes_or_observations,
    interactions         = interactions_with_humans,
    squirrel_lat         = squirrel_latitude_dd_dddddd,
    squirrel_lon         = squirrel_longitude_dd_dddddd
  ) |>
  mutate(
    # Fix encoding corruption in height column (e.g. "20‰ÛÒ40" → "20-40")
    above_ground_ft = str_replace_all(above_ground_ft, "[^0-9a-zA-Z<>. /-]+", "-"),
    # Numeric version: single values parsed, ranges (and "< 1") become NA
    above_ground_ft_num = suppressWarnings(as.numeric(above_ground_ft))
  )


# ── stories ────────────────────────────────────────────────────────────────────
stories_clean <- stories_raw |>
  clean_names() |>
  rename(story = squirrels_parks_the_city_stories)


# ── Save cleaned datasets ──────────────────────────────────────────────────────
write_csv(park_clean,     "park-data-clean.csv")
write_csv(squirrel_clean, "squirrel-data-clean.csv")
write_csv(stories_clean,  "stories-clean.csv")

message("Cleaning complete. Saved: park-data-clean.csv, squirrel-data-clean.csv, stories-clean.csv")
