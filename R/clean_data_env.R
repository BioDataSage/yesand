library(tidyverse)
library(janitor)

# ── Load raw data ──────────────────────────────────────────────────────────────
squirrel_raw <- read_csv("squirrel-data.csv")
parks_raw    <- read_csv("park-data.csv")
stories_raw  <- read_csv("stories.csv")


# ── Squirrel data ──────────────────────────────────────────────────────────────
squirrel <- squirrel_raw |>
  clean_names() |>
  rename(
    lat = squirrel_latitude_dd_dddddd,
    lon = squirrel_longitude_dd_dddddd,
    height_ft = above_ground_height_in_feet
  ) |>
  # Flag rows with valid GPS coordinates
  mutate(has_coords = !is.na(lat) & !is.na(lon)) |>
  # Split location into two logical columns
  mutate(
    above_ground    = str_detect(location, "Above Ground"),
    specific_location_flag = str_detect(location, "Specific Location"),
    # Preserve NA where location itself is NA
    above_ground    = if_else(is.na(location), NA, above_ground),
    specific_location_flag = if_else(is.na(location), NA, specific_location_flag)
  ) |>
  select(-location) |>
  # Parse height: extract lower bound of ranges, coerce corrupted strings to NA
  mutate(
    height_ft = str_extract(height_ft, "^\\d+"),  # take leading digits only
    height_ft = as.numeric(height_ft)
  ) |>
  # Split Activities into dummy columns
  mutate(
    activity_foraging = str_detect(activities, regex("Foraging", ignore_case = TRUE)),
    activity_eating   = str_detect(activities, regex("Eating",   ignore_case = TRUE)),
    activity_climbing = str_detect(activities, regex("Climbing", ignore_case = TRUE)),
    activity_running  = str_detect(activities, regex("Running",  ignore_case = TRUE)),
    activity_chasing  = str_detect(activities, regex("Chasing",  ignore_case = TRUE)),
    activity_sitting  = str_detect(activities, regex("Sitting",  ignore_case = TRUE)),
    activity_digging  = str_detect(activities, regex("Digging",  ignore_case = TRUE)),
    # Preserve NA where activities is NA
    across(starts_with("activity_"), \(x) if_else(is.na(activities), NA, x))
  ) |>
  select(-activities) |>
  # Split Interactions with Humans into dummy columns
  mutate(
    interaction_indifferent = str_detect(interactions_with_humans, regex("Indifferent", ignore_case = TRUE)),
    interaction_approaches  = str_detect(interactions_with_humans, regex("Approaches",  ignore_case = TRUE)),
    interaction_runs_from   = str_detect(interactions_with_humans, regex("Runs From",   ignore_case = TRUE)),
    across(starts_with("interaction_"), \(x) if_else(is.na(interactions_with_humans), NA, x))
  ) |>
  select(-interactions_with_humans)


# ── Park data ──────────────────────────────────────────────────────────────────
parks <- parks_raw |>
  clean_names() |>
  rename(
    n_squirrels  = number_of_squirrels,
    n_sighters   = number_of_sighters,
    total_min    = total_time_in_minutes_if_available
  ) |>
  # Parse date
  mutate(date = as.Date(date, format = "%m/%d/%y")) |>
  # Split temperature & weather into numeric temp and description
  mutate(
    temp_f = str_extract(temperature_weather, "\\d+(?=\\s*degrees?)") |> as.numeric(),
    weather_description = case_when(
      is.na(temperature_weather) ~ NA_character_,
      # Has a numeric temp followed by comma: strip the "XX degrees, " prefix
      str_detect(temperature_weather, "\\d+\\s*degrees?,\\s*") ~
        str_remove(temperature_weather, "^.*?degrees?,\\s*") |> str_trim(),
      # Has a parseable temp but no conditions after it: no description
      str_detect(temperature_weather, "^\\d+\\s*degrees?$") ~ NA_character_,
      # No parseable temperature: keep the whole string as description
      TRUE ~ temperature_weather
    )
  ) |>
  select(-temperature_weather) |>
  # Standardize Park Conditions to core categories
  mutate(
    park_conditions = case_when(
      str_detect(park_conditions, regex("^Busy",   ignore_case = TRUE)) ~ "Busy",
      str_detect(park_conditions, regex("^Calm",   ignore_case = TRUE)) ~ "Calm",
      str_detect(park_conditions, regex("^Medium", ignore_case = TRUE)) ~ "Medium",
      is.na(park_conditions) ~ NA_character_,
      TRUE ~ NA_character_  # free-text that doesn't match a core category
    )
  ) |>
  # Standardize Litter to core categories
  mutate(
    litter = case_when(
      str_detect(litter, regex("^None",     ignore_case = TRUE)) ~ "None",
      str_detect(litter, regex("^Some",     ignore_case = TRUE)) ~ "Some",
      str_detect(litter, regex("^Abundant", ignore_case = TRUE)) ~ "Abundant",
      is.na(litter) ~ NA_character_,
      TRUE ~ NA_character_
    ),
    litter = factor(litter, levels = c("None", "Some", "Abundant"))
  )


# ── Stories data ───────────────────────────────────────────────────────────────
stories <- stories_raw |>
  clean_names() |>
  rename(story = squirrels_parks_the_city_stories)
