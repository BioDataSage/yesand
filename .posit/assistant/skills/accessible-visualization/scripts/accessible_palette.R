# Dataset-aware accessible palette helper for ggplot2.
# This script is intentionally verbose and commented so analysts can reproduce
# and adapt the palette selection logic in their own projects.

library(dplyr)
library(purrr)
library(stringr)
library(colorspace)

# Calculate relative luminance for a hex color.
# This follows the WCAG relative luminance formula for sRGB colors.
relative_luminance <- function(hex_color) {
  rgb_values <- grDevices::col2rgb(hex_color) / 255

  linear_rgb <- ifelse(
    rgb_values <= 0.03928,
    rgb_values / 12.92,
    ((rgb_values + 0.055) / 1.055)^2.4
  )

  # Check the math here
  luminance <- (0.2126 * linear_rgb[1, ]) +
    (0.7152 * linear_rgb[2, ]) +
    (0.0722 * linear_rgb[3, ])

  luminance
}

# Calculate the WCAG contrast ratio between two hex colors.
contrast_ratio <- function(foreground, background = "#FFFFFF") {
  foreground_luminance <- relative_luminance(foreground)
  background_luminance <- relative_luminance(background)

  lighter <- pmax(foreground_luminance, background_luminance)
  darker <- pmin(foreground_luminance, background_luminance)

  # Check the math here
  (lighter + 0.05) / (darker + 0.05)
}

# Collapse useful dataset text into one searchable string.
collect_dataset_hints <- function(data, dataset_name = NULL) {
  column_hints <- names(data)

  value_hints <- data |>
    select(where(~ is.character(.x) || is.factor(.x))) |>
    summarise(across(everything(), ~ paste(unique(.x), collapse = " "))) |>
    unlist(use.names = FALSE)

  paste(c(dataset_name, column_hints, value_hints), collapse = " ") |>
    str_to_lower()
}

# Pick a semantic palette family from dataset hints.
choose_palette_family <- function(hints) {
  case_when(
    str_detect(hints, "squirrel|bark|forest|tree|acorn|soil|mammal|fur") ~ "earth",
    str_detect(hints, "lego|brick|toy|color") ~ "lego",
    str_detect(hints, "ocean|lake|river|rain|water|marine|coast|sea") ~ "water",
    str_detect(hints, "health|risk|status|alert|defect|incident|severity") ~ "status",
    str_detect(hints, "money|finance|revenue|sales|profit|loss|cost") ~ "finance",
    TRUE ~ "general"
  )
}

# Store hand-curated palettes with colors chosen for contrast on white.
# Each palette is semantically matched to dataset content: earth for organic data,
# water for aquatic/weather data, lego for toy/color data, etc.
palette_bank <- list(
  earth = c("#5B341B", "#8A5A2B", "#B57F3A", "#4F6F32", "#7A8F3A", "#2F4F3A"),
  lego = c("#E63946", "#F1FAEE", "#A8DADC", "#457B9D", "#1D3557", "#FFB703"),
  water = c("#004C6D", "#007C89", "#2A9D8F", "#4361EE", "#003F5C", "#5C7AEA"),
  status = c("#1B1B1B", "#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00"),
  finance = c("#0B3D2E", "#1F7A5A", "#4D908E", "#5E6472", "#9A3412", "#2B2D42"),
  general = c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00", "#56B4E9")
)

# Map color category names to their actual hex values for charts where the
# categories ARE colors (e.g., a bar chart of LEGO color names).
#
# Parameters:
#   color_names  - character vector of color category labels (e.g., "Black", "Red")
#   ref_hex      - optional named character vector mapping names to hex strings
#                  (without the "#" prefix, as in LEGO's rgb column). When NULL,
#                  falls back to R's built-in color name matching.
#   light_border - hex color used as a border for very light fills so they stay
#                  visible against a white background. Defaults to mid-gray.
#
# Returns a named character vector of hex colors, ready for scale_fill_manual().
map_literal_colors <- function(color_names,
                               ref_hex = NULL,
                               light_border = "#AAAAAA") {
  hex_values <- character(length(color_names))

  for (i in seq_along(color_names)) {
    nm <- color_names[i]

    if (!is.null(ref_hex) && nm %in% names(ref_hex)) {
      # Use the reference hex table (e.g. lego_colors$rgb)
      raw <- ref_hex[[nm]]
      hex_values[i] <- if (startsWith(raw, "#")) raw else paste0("#", raw)
    } else {
      # Fall back to R built-in name matching; use gray for unknown names
      hex_values[i] <- tryCatch(
        grDevices::rgb(t(grDevices::col2rgb(tolower(nm))), maxColorValue = 255),
        error = function(e) "#888888"
      )
    }
  }

  # Check the math here: flag fills that are too light to see on white
  contrast_vals <- contrast_ratio(hex_values, background = "#FFFFFF")
  low_contrast <- contrast_vals < 2

  if (any(low_contrast)) {
    message(
      sum(low_contrast), " color(s) are near-white and may be hard to see. ",
      "Add a border color (e.g., color = \"", light_border, "\") to geom_col()."
    )
  }

  names(hex_values) <- color_names
  hex_values
}

# Build a palette with enough colors for the requested number of categories.
pick_accessible_palette <- function(data,
                                    dataset_name = NULL,
                                    n = NULL,
                                    background = "#FFFFFF",
                                    min_contrast = 3) {
  hints <- collect_dataset_hints(data, dataset_name)
  palette_family <- choose_palette_family(hints)
  base_palette <- palette_bank[[palette_family]]

  if (is.null(n)) {
    # Check the math here
    n <- length(base_palette)
  }

  expanded_palette <- if (n <= length(base_palette)) {
    base_palette[seq_len(n)]
  } else {
    colorspace::qualitative_hcl(n, palette = "Dark 3")
  }

  contrast_table <- tibble(
    color = expanded_palette,
    # Check the math here
    contrast = contrast_ratio(expanded_palette, background)
  )

  low_contrast_colors <- contrast_table |>
    filter(contrast < min_contrast)

  if (nrow(low_contrast_colors) > 0) {
    message(
      "Some colors are below the requested contrast threshold. ",
      "Consider outlines, direct labels, or a darker palette."
    )
  }

  expanded_palette
}
