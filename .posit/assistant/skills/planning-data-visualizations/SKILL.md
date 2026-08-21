---
name: planning-data-visualizations
description: Plans intentional data visualizations by building a narrative and story arc from analytics-metrics outputs before writing ggplot2 code. Use when creating charts from metrics, KPIs, or analytical summaries, or when the user wants a more purposeful, story-driven, or intentional visualization.
license: MIT
compatibility: R with tidyverse, ggplot2. Works alongside the accessible-visualization and analytics-metrics skills.
metadata:
  author: local
  version: "1.0.0"
---
# Planning Data Visualizations

Use this skill when building charts from metric outputs (such as those produced by the `analytics-metrics` skill). The goal is to define the story **before** writing any ggplot2 code, so every aesthetic, annotation, and layout choice serves the narrative.

## Workflow

### Step 1: Extract the insight

Review the analytics-metrics output. Identify:

- The single most important finding (the "headline")
- What changed, is surprising, or demands attention
- The relevant comparison: over time, across groups, or against a target

Write the insight as one sentence:
*"[Metric] [did what] among [group or period], compared to [baseline or expectation]."*

If you cannot write that sentence, the metric output needs more interpretation before proceeding.

### Step 2: Choose the chart type

Match the insight type to a chart:

| Insight type | Recommended chart |
|---|---|
| Change over time | Line chart or area chart |
| Comparing groups | Bar chart (ordered by value) |
| Part-of-whole | Stacked bar or waffle chart |
| Distribution shape | Histogram or density plot |
| Relationship between two metrics | Scatter plot |
| Single KPI vs. target | Annotated bar or bullet chart |

Default to the simplest chart that communicates the insight. Avoid combining chart types unless each adds distinct information.

### Step 3: Plan the narrative elements

Before writing any ggplot2 code, specify all text elements:

- **Title**: State the conclusion, not just the topic. Use *"Revenue peaked in Q3 before declining"*, not *"Revenue over time"*.
- **Subtitle**: Add context — the time window, units, or population included.
- **Annotations**: Identify the one or two specific data points that carry the story (peaks, thresholds, outliers, targets). Plan their placement and label text.
- **Caption**: Note the data source and date range.

### Step 4: Plan aesthetic choices

Every aesthetic choice should reduce noise or reinforce the insight:

- **Color**: Use one highlight color for the marks that carry the insight. All other marks should be muted (gray or low-saturation). Do not map color to a variable already encoded on an axis.
- **Ordering**: Order categorical axes by the metric being compared, not alphabetically, unless the order itself is the story.
- **Faceting**: Use facets only when a comparison would otherwise require multiple separate charts.
- **Labels vs. legend**: Use direct labels on lines or bars when there are 5 or fewer series. Remove the legend when direct labels are present.

### Step 5: Write the narrative summary

Produce this block before writing any code:

```
Insight:      [one-sentence finding]
Chart type:   [type and why it fits the insight]
Title:        [draft title — states the conclusion]
Subtitle:     [draft subtitle — adds context]
Annotations:  [specific data points to label, with planned label text]
Highlight:    [which marks use the highlight color and why]
Caption:      [source and date range]
```

### Step 6: Execute with ggplot2

Write the ggplot2 code using these conventions:

- Prepare data before the `ggplot()` call. Keep filtering, grouping, and label logic out of `aes()`.
- Use `annotate()` or `ggrepel::geom_label_repel()` to add the narrative annotations from Step 3.
- Use `labs()` for all text: title, subtitle, axis labels, and caption.
- Use `scale_*_manual()` to apply the highlight-and-mute color scheme.
- Whenever code performs math or a calculation, add a comment: `# Check the math here`.
- Reference the **accessible-visualization** skill for palette selection, WCAG contrast checking, and final code standards.

### Step 7: Scan for secondary findings

After the primary chart is complete, examine it — and the data behind it — for patterns that weren't the original question. This step is how exploratory analysis deepens beyond its starting point.

**Look for these signals:**

| Signal | What to check |
|---|---|
| Unexpected spike or dip | Break the metric down by a secondary dimension (group, category, department) to isolate what drove it |
| A flat aggregate that hides variation | Facet or filter by subgroup to see if the groups are moving in opposite directions |
| A ranking chart with one extreme outlier | Compare the outlier's composition (time period, source, type) to the median |
| A trend that diverges after a date | Check whether the divergence is universal or isolated to a subset |
| A dominant group that may mask others | Remove or normalize the dominant group and re-examine the remaining data |

**Secondary finding workflow:**

1. Write the secondary insight as a sentence, the same way you would for a primary finding.
2. Decide whether it belongs in the same chart (annotation, facet) or deserves its own.
3. If it deserves its own chart, return to Step 2 and plan it fully before building it.
4. Flag secondary findings clearly so the audience knows they arose from exploration, not a pre-specified hypothesis.

**When to stop:**

Not every secondary signal justifies a chart. Skip it if:
- The subgroup sample is too small to support reliable conclusions.
- The pattern is consistent with a known explanation that adds no new insight.
- It would require introducing a new variable not yet examined for data quality.

## Output Format

Present the narrative plan before any code. Use bullet points:

- **Insight**: The one finding the chart communicates.
- **Chart type**: The chosen type and why it fits.
- **Narrative elements**: Title, subtitle, annotation targets, and caption.
- **Aesthetic plan**: Color strategy, ordering, and faceting decisions.
- **Code**: ggplot2 implementation following the accessible-visualization reproducible plot pattern.
- **Secondary signals** (if present): Any anomalies or breakdowns noticed after building the chart, with a brief plan for whether and how to explore them.

## Integration with Other Skills

- **analytics-metrics**: Use that skill first to define, calculate, and validate the metrics. Bring those outputs into Step 1 of this skill.
- **accessible-visualization**: Delegate palette selection, WCAG contrast checking, and ggplot2 code standards to that skill during Step 6.
