---
name: accessible-visualization
description: Use this skill when creating ggplot2 visualizations in R, especially when the chart should use a dataset-aware accessible color palette. It emphasizes WCAG-aware contrast checks, semantic palette selection, ggplot2 best practices, and thoroughly commented reproducible plotting code.
license: MIT
compatibility: R with tidyverse, ggplot2, colorspace
metadata:
  author: local
  version: "1.0.0"
---
# Accessible Visualization

Use this skill for R visualization work where the assistant needs to create clear, reproducible, accessible charts with `ggplot2`.

## Core Practices

- Use tidyverse and `ggplot2` conventions.
- Comment plotting code thoroughly so readers can reproduce the chart and understand every transformation.
- Whenever code performs math or a calculation, add a nearby comment that says exactly: `Check the math here`.
- Use a dataset-aware accessible palette picker before creating charts.
- Choose palettes that fit the data content when possible. For example:
  - Squirrel, forest, bark, soil, coffee, or mammal datasets should consider brown and green palettes.
  - Ocean, lake, rainfall, or water datasets should consider blue and teal palettes.
  - Finance, operations, or status datasets should use restrained, high-contrast categorical palettes.
- Check color contrast against the plot background and avoid low-contrast color choices.
- Do not rely on color alone. Add labels, facets, line types, point shapes, direct annotations, or ordering when they improve interpretation.

## Palette Selection Rules

Use the helper in `scripts/accessible_palette.R` when possible.

The palette picker should:

1. Inspect dataset names, column names, and factor values for semantic hints.
2. Select a theme-appropriate palette family.
3. Use colors with adequate contrast against the background.
4. Preserve categorical meaning by mapping stable levels to stable colors.
5. Fall back to a general high-contrast accessible palette when no semantic match is found.

WCAG contrast is most relevant for text and essential graphical marks. For chart fills, aim for clear perceptual separation and sufficient contrast with labels, outlines, and the plot background.

### Literal Color Mapping

When the categories being visualized **are themselves colors** (e.g., bars representing "Black", "Red", "White"), always use the actual color values for the fills rather than a thematic palette. This makes the chart self-explanatory and eliminates arbitrary color assignment.

Use `map_literal_colors()` from `scripts/accessible_palette.R` for this case. It:

- Accepts a vector of color names and an optional reference table with hex values (e.g., from a LEGO or paint dataset)
- Falls back to R's built-in `col2rgb()` name matching for standard color names
- Adds a visible border to very light colors (contrast < 2 against white) so they remain visible on a white background
- Returns a named character vector ready for `scale_fill_manual(values = ...)`

Use `map_literal_colors()` any time the chart's fill aesthetic encodes categories that are themselves color names. Use `pick_accessible_palette()` for all other categorical data.

## ggplot2 Best Practices

- Start with a tidy data frame: one observation per row and one variable per column.
- Put data preparation before plotting, not inside long `ggplot()` calls.
- Use explicit `aes()` mappings and clear variable names.
- Order categories by the metric being plotted when it improves scanning.
- Prefer direct labels over legends when there are only a few series.
- Use `coord_cartesian()` for zooming so data is not dropped accidentally.
- Use `scale_*_continuous(labels = scales::label_*)` for percentages, currency, and large numbers.
- Use `labs()` for title, subtitle, axis labels, color/fill labels, and captions.
- Use `theme_minimal()` or another clean theme as a base, then adjust only what is needed.
- Save plots with explicit width, height, units, and DPI.

## Reproducible Plot Pattern

```r
library(tidyverse)
library(colorspace)

source(".posit/assistant/skills/accessible-visualization/scripts/accessible_palette.R")

plot_data <- raw_data |>
  filter(!is.na(category), !is.na(value)) |>
  group_by(category) |>
  summarise(
    # Check the math here
    total_value = sum(value, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(total_value))

plot_palette <- pick_accessible_palette(
  data = plot_data,
  dataset_name = "squirrel_observations",
  n = n_distinct(plot_data$category)
)

ggplot(plot_data, aes(x = reorder(category, total_value), y = total_value, fill = category)) +
  geom_col(width = 0.72, color = "white", linewidth = 0.3) +
  coord_flip() +
  scale_fill_manual(values = plot_palette) +
  scale_y_continuous(labels = scales::label_number()) +
  labs(
    title = "Observed squirrels by category",
    x = NULL,
    y = "Observation count",
    fill = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    panel.grid.major.y = element_blank()
  )
```

## Output Expectations

When presenting visualization choices, use bullet points:

- Chart purpose:
  State the comparison, trend, distribution, or relationship the chart supports.
- Palette:
  Explain why the palette was selected and whether it was driven by dataset content.
- Accessibility:
  Note contrast, redundant encodings, labels, and any limitations.
- Reproducibility:
  Point to the data preparation, palette selection, plotting, and export steps.
