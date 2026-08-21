---
name: quarto-report-generation
description: Generates concise, accessible HTML reports from data analysis using Quarto. Combines analytics-metrics, planning-data-visualizations, and accessible-visualization skills to create ADA-compliant reports with intentional narratives, code details in collapsible sections, and accessible color palettes. Use when creating a final data analysis report with specific story and findings.
license: MIT
metadata:
  author: local
  version: "1.0.0"
---

# Quarto Report Generation

Use this skill to convert data analysis into a polished, concise HTML report optimized for ADA accessibility and narrative clarity.

## Core Approach

Reports from this skill follow these principles:

- **Narrative-driven**: Lead with insight, not data. The report tells a story supported by findings.
- **Concise**: Only include information that answers the core question. Remove exploratory notes, redundant tables, and tangential findings.
- **Code transparency**: Show working code in collapsible `<details>` sections so readers can verify logic without clutter.
- **Accessible**: Use semantic HTML, sufficient color contrast (WCAG AA), alt text for all images, and clear hierarchies.
- **Self-contained**: All data, code, and visualizations are included; the report needs no external dependencies.

## Workflow

## User Checkpoint Rules

Use short, decision-focused prompt pauses throughout the workflow. Make the user a partner in choices that affect the question, method, story, or final interpretation.

- Batch related decisions into one `AskUser` call.
- Present a recommended default and one or two meaningful alternatives.
- Treat an instruction already supplied by the user as confirmed. Do not ask again.
- Record each confirmed choice so it can appear in the report's methodology or notes.
- Do not move past a checkpoint until the user has selected, revised, or explicitly delegated the decision.

### Step 0: Frame the report with the user

Before analyzing data, confirm the report's purpose when it is not already clear. Use `AskUser` to agree on:

- **Question**: The decision or topic the report should answer
- **Audience**: Who will read the report and what they need to take away
- **Scope**: Dataset, time period, population, and any required comparisons
- **Output**: Desired report length, number of findings, and whether a rendered HTML report is wanted

Summarize the selected framing in one or two sentences before continuing.

### Step 1: Identify findings from analytics-metrics

From your metrics calculations, extract:
- **Core metric**: The main number or result
- **Confidence**: Any caveats about sample size, missingness, or outliers
- **Comparison**: How this metric compares to a baseline, previous period, or expectation

Write these as bullet points in plain language.

### Step 1b: Confirm calculations and mathematical decisions with the user

Before proceeding to visualization or report writing, surface every calculation and mathematical decision made during analytics-metrics to the user for explicit confirmation. Use `AskUser` to present each decision as a structured question.

For each calculation or decision, confirm:
- **What was computed**: The formula or aggregation used (e.g., "median acquisition lag = median of `year_acquired - year_created`")
- **Why that method**: The reasoning behind the choice (e.g., "used median instead of mean to reduce influence of outliers")
- **Exclusions or filters applied**: Any rows dropped, NA values removed, or subsets selected, and the rationale
- **Denominators and scope**: What the denominator is in any ratio or percentage, and what population it represents

Group related decisions into as few `AskUser` calls as possible (batch them when they are logically connected). Present the decisions as a summary table or bullet list in the question text so the user can scan them quickly.

**Only proceed to Step 2 after the user has confirmed or corrected each calculation.** If the user corrects a decision, update the metric accordingly before moving on.

Log each confirmed decision for inclusion in the report (see Step 4 below).

### Step 2: Plan visualizations with planning-data-visualizations

For each key finding:
- State the insight in one sentence
- Choose a chart type matched to the insight (trend, comparison, distribution, relationship)
- Plan all text: title states the conclusion, not the topic
- Specify the highlight color strategy: one accent color, muted background

### Step 2b: Confirm the story and visualization plan with the user

Before building final charts, use `AskUser` to present the proposed findings in a compact table or list. For each finding, show:

- **Conclusion**: The takeaway title
- **Evidence**: The metric and comparison that support it
- **Visual**: The planned chart type and what will be highlighted
- **Caveat**: The most important limitation the reader should know

Ask the user to approve the plan, choose a different emphasis, or remove a finding. Update the plan before chart implementation.

### Step 3: Execute visualizations with accessible-visualization

Use earth tones, water tones, or status tones matched to your dataset.
Always check WCAG contrast against the white plot background.
Use direct labels instead of legends when possible.

### Step 3b: Pause for evidence review

After producing draft visuals, show the user the proposed conclusion, chart preview, and caveat together. Use `AskUser` to confirm that:

- The title says what the evidence supports
- The visual makes the intended comparison easy to see
- The caveat is proportionate to the uncertainty

If the user changes the conclusion, metric, or scope, return to the relevant earlier step and update the analysis before drafting the report.

### Step 4: Write the report in Quarto

Use this template structure:

````markdown
---
title: "[Concise title stating the finding, not the analysis]"
author: "[Name/team]"
date: today
format:
  html:
    theme: default
    toc: true
    toc-depth: 2
    code-fold: true
    code-summary: "Code"
    html-math-method: katex
---

# Overview

[One paragraph: what question was asked, what data was used, what was found.]

# Key Finding 1

## Insight

[One sentence stating the main conclusion.]

### Context

- **Metric**: Definition in plain language
- **Grain**: What each row represents
- **Scope**: Time period, population, exclusions
- **Data quality**: Notes on missingness or uncertainty

### Confirmed methodology

[Summarize the calculation decisions confirmed with the user in Step 1b. For each decision, include:]

- **Calculation**: What was computed and the exact formula or aggregation
- **Method rationale**: Why this method was chosen (as confirmed by the user)
- **Exclusions**: Any filters or NA removals applied, with rationale
- **Denominator / scope**: What population the metric covers

_These decisions were reviewed and confirmed before the report was finalized._

### Main result

[The number. Use inline code for the metric name.]

### Visual

[Render the ggplot2 chart.]

::: {.details}
<summary>Calculation details</summary>

[Code block showing the calculation. Use code-fold: true so it's collapsible by default.]

:::

# Key Finding 2

[Repeat the structure above for each major finding.]

# Notes

- [Caveat 1: e.g., small sample size, missing data pattern]
- [Caveat 2: e.g., data collection method, timing]

# Code appendix

[Optional section with full script if useful for reproducibility.]
````

### Step 4b: Confirm the report draft before rendering

Before rendering or overwriting a report, share the proposed title, finding titles, confirmed methodology summary, and caveats. Use `AskUser` to request approval or revisions. Render only after the user approves the draft or explicitly delegates the final editorial decisions.

### Step 5: Render to HTML

Run in R:

```r
quarto::quarto_render("report.qmd", output_format = "html")
```

## Accessibility Checklist

- [ ] Images have meaningful alt text via `fig-alt` in code blocks
- [ ] All text passes WCAG AA contrast (4.5:1 for body, 3:1 for large text)
- [ ] Headings follow hierarchy (h1 → h2 → h3, no skipping)
- [ ] No information is conveyed by color alone (always add text labels or patterns)
- [ ] Tables use `<th>` scope for headers
- [ ] Links are descriptive (avoid "click here"; use "see findings summary")
- [ ] Code blocks have a descriptive language tag (```r not ```)

## Output Expectations

Present the report as a self-contained HTML file. Include:

- **Title**: States the insight or main finding, not "Data Analysis Report"
- **Executive summary**: 1–2 paragraphs answering the core question
- **Findings**: 2–4 key insights, each with context, result, and visualization
- **Confirmed methodology**: For each finding, a summary of the calculation decisions confirmed with the user (formula, method rationale, exclusions, denominator), placed under a "Confirmed methodology" subsection within each finding
- **Caveats**: Clear statement of limitations and uncertainty
- **Reproducibility**: Code visible via `code-fold: true` or in appendix

## Integration with Other Skills

- **analytics-metrics**: Extract metric definitions, calculate key statistics, validate denominators
- **planning-data-visualizations**: Build the narrative plan before any visualization code
- **accessible-visualization**: Delegate palette selection, contrast checking, and ggplot2 implementation
