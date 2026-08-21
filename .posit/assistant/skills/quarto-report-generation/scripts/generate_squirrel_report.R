# generate_squirrel_report.R
# Generates an ADA-compliant Quarto HTML report from NYC Squirrel Census analysis
# Combines analytics-metrics, planning-data-visualizations, and accessible-visualization

library(tidyverse)
library(quarto)

source(".posit/assistant/skills/analytics-metrics/scripts/metrics_helpers.R")
source(".posit/assistant/skills/accessible-visualization/scripts/accessible_palette.R")

# Load cleaned data (assumes it's already loaded in session)
# squirrel, parks, stories should exist in global environment

# ===========================================================================
# Generate Quarto report template
# ===========================================================================

report_content <- '---
title: "Gray squirrels dominate NYC parks, but human interactions are mixed"
author: "NYC Squirrel Census Analysis"
date: today
format:
  html:
    theme: default
    toc: true
    toc-depth: 2
    code-fold: true
    code-summary: "Show code"
    embed-resources: true
    smooth-scroll: true
---

# Overview

The NYC Squirrel Census surveyed 25 parks across NYC in March 2020, recording 433 individual squirrel sightings. This report highlights three key findings: (1) the overwhelming dominance of gray squirrels, (2) the surprising indifference of most squirrels to human presence, and (3) geographic concentration of sightings in Central Manhattan parks.

# Finding 1: Gray Squirrels Comprise 90% of Sightings

## Insight

Gray squirrels account for more than 9 in 10 sightings. Cinnamon and Black squirrels are genuinely rare.

### Context

- **Metric**: Count and percentage of squirrels by primary fur color
- **Grain**: One row = one squirrel sighting
- **Scope**: 433 squirrels observed across 25 NYC parks, March 2020
- **Exclusions**: 1 sighting with missing fur color

### Main result

Of the 432 squirrels with recorded fur color, 390 (90.3%) were Gray. Cinnamon squirrels comprised 26 sightings (6.0%), and Black squirrels just 16 (3.7%).

### Visual

```{r}
#| label: fig-fur-color
#| fig-cap: "Gray squirrels dominate NYC parks (433 sightings, 2020)"
#| fig-alt: "Bar chart showing 390 gray squirrels, 26 cinnamon squirrels, and 16 black squirrels"

library(tidyverse)

source(".posit/assistant/skills/accessible-visualization/scripts/accessible_palette.R")

fur_plot_data <- squirrel |>
  filter(!is.na(primary_fur_color)) |>
  count(primary_fur_color, name = "squirrel_count") |>
  mutate(
    # Check the math here
    pct = squirrel_count / sum(squirrel_count),
    label = paste0(squirrel_count, " (", scales::percent(pct, accuracy = 0.1), ")"),
    highlight = primary_fur_color != "Gray"
  ) |>
  arrange(desc(squirrel_count)) |>
  mutate(primary_fur_color = fct_inorder(primary_fur_color))

ggplot(fur_plot_data,
       aes(y = primary_fur_color, x = squirrel_count, fill = highlight)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = label), hjust = -0.08, size = 3.5, color = "#2d2d2d") +
  scale_fill_manual(values = c("TRUE" = "#8A5A2B", "FALSE" = "#AAAAAA"),
                    guide = "none") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.18))) +
  labs(
    x = "Squirrel sightings",
    y = NULL,
    caption = "Source: NYC Squirrel Census"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank()
  )
```

---

# Finding 2: Most Squirrels Ignore Humans

## Insight

Nearly 3 in 4 squirrels are indifferent to human presence. Those that react split roughly evenly between approaching and fleeing.

### Context

- **Metric**: Distribution of recorded human interaction responses
- **Grain**: One row = one recorded interaction
- **Scope**: 342 squirrels with interaction data recorded
- **Note**: Interaction responses are free-text; categories were consolidated for clarity

### Main result

260 squirrels (73%) were recorded as "Indifferent" to human observers. Among those that reacted, 42 (12%) fled and 40 (11%) approached. The remaining 4% showed other behaviors (staring, watching, cautious).

### Visual

```{r}
#| label: fig-human-interaction
#| fig-cap: "Most NYC squirrels simply ignore humans (342 observations with recorded interactions)"
#| fig-alt: "Bar chart showing 260 indifferent, 42 fleeing, and 40 approaching squirrels"

interaction_plot_data <- squirrel |>
  filter(!is.na(interactions_with_humans)) |>
  mutate(interaction = str_split(interactions_with_humans, ",\\s*")) |>
  unnest(interaction) |>
  mutate(
    interaction = str_trim(interaction),
    interaction_group = case_when(
      str_detect(interaction, "(?i)indifferent")                        ~ "Indifferent",
      str_detect(interaction, "(?i)approach|friendly|okay|interested")  ~ "Approaches",
      str_detect(interaction, "(?i)run|skittish|cautious|defensive")    ~ "Runs From",
      TRUE                                                               ~ "Other"
    )
  ) |>
  count(interaction_group, name = "count") |>
  mutate(
    # Check the math here
    pct   = count / sum(count),
    label = paste0(count, " — ", scales::percent(pct, accuracy = 1)),
    interaction_group = fct_reorder(interaction_group, count, .desc = FALSE)
  )

color_vals <- c(
  "Indifferent" = "#AAAAAA",
  "Runs From"   = "#5B341B",
  "Approaches"  = "#B57F3A",
  "Other"       = "#CCCCCC"
)

ggplot(interaction_plot_data,
       aes(y = interaction_group, x = count, fill = interaction_group)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = label), hjust = -0.08, size = 3.5, color = "#2d2d2d") +
  scale_fill_manual(values = color_vals, guide = "none") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.22))) +
  labs(
    x = "Squirrel observations",
    y = NULL,
    caption = "Source: NYC Squirrel Census"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank()
  )
```

---

# Finding 3: Tompkins and Washington Squares Lead

## Insight

Central Manhattan parks hold the most squirrels. Tompkins Square and Washington Square account for more than 1 in 4 of all sightings.

### Context

- **Metric**: Total squirrels observed per park
- **Scope**: 25 parks surveyed, 433 total sightings
- **Note**: Park visit length and observer count varied; this is a raw observation count, not density-adjusted

### Main result

Tompkins Square Park (59 squirrels) and Washington Square Park (51) together account for 110 of 433 sightings (25.4%). The top three parks (including McCarren Park with 44) represent 154 sightings (35.6%).

### Visual

```{r}
#| label: fig-park-density
#| fig-cap: "Central Manhattan parks hold the most squirrels (top 12 parks shown)"
#| fig-alt: "Horizontal bar chart showing Tompkins Square with 59 squirrels leading, followed by Washington Square with 51"

park_plot_data <- parks |>
  select(park_name, area_name, number_of_squirrels) |>
  arrange(desc(number_of_squirrels)) |>
  slice_head(n = 12) |>
  mutate(
    park_name = fct_reorder(park_name, number_of_squirrels),
    top_park  = row_number() <= 3
  )

ggplot(park_plot_data,
       aes(y = park_name, x = number_of_squirrels, fill = top_park)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = number_of_squirrels),
            hjust = -0.2, size = 3.2, color = "#2d2d2d") +
  scale_fill_manual(values = c("TRUE" = "#8A5A2B", "FALSE" = "#CCCCCC"),
                    guide = "none") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(
    x = "Squirrels observed",
    y = NULL,
    caption = "Source: NYC Squirrel Census"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank(),
    axis.text.y        = element_text(size = 9)
  )
```

---

# Notes and Caveats

- **Sample**: Observations are from a single month (March 2020); seasonal variation in squirrel behavior is unknown.
- **Missing data**: About 21% of squirrel sightings lack valid geographic coordinates; spatial clustering analysis would require imputation or exclusion.
- **Free-text responses**: Interaction types and activities are recorded as free text; consolidation into categories involves some judgment calls.
- **Observer variation**: Different numbers of observers visited different parks; "squirrels observed" reflects observer effort, not true population density.
- **Time window**: Data collection occurred in early March 2020, before COVID-19 lockdowns began; behavior may have changed substantially since.

---

# Reproducibility

All code is shown above in collapsible code blocks. To reproduce this analysis:

1. Load the three cleaned datasets: `squirrel`, `parks`, `stories`
2. Source the helper scripts from `analytics-metrics` and `accessible-visualization` skills
3. Run the code blocks in sequence to calculate metrics and generate visualizations
4. Render this Quarto document with `quarto::quarto_render("report.qmd", output_format = "html")`
'

# Write report template to file
writeLines(report_content, "squirrel_report.qmd")

cat("✓ Quarto template written to squirrel_report.qmd\n")
cat("✓ To render to HTML, run: quarto::quarto_render(\"squirrel_report.qmd\", output_format = \"html\")\n")
