# Yes, and

Use this repository as a template for R data-analysis projects that uses skills. The included skills provide a connected workflow: define and validate metrics, plan a data story, build accessible visualizations, and produce an accessible Quarto report.

## Start a project from this template

1. Select **Use this template** on GitHub, then name your new repository.
2. Add your data and analysis code to the project.
3. Keep the `.posit/assistant/skills/` folder in the repository so the project’s instructions travel with it.
4. Open the project in Posit/RStudio and ask the assistant to use the skill that fits your task.

## Included skills

| Skill | Use it when you need to | Example request |
|---|---|---|
| `analytics-metrics` | inspect data, define a metric, compare groups, or validate an analysis | “Use `analytics-metrics` to calculate monthly retention and flag data-quality issues.” |
| `planning-data-visualizations` | turn metrics into a clear chart narrative before writing plotting code | “Use `planning-data-visualizations` to plan the most important chart from these KPIs.” |
| `accessible-visualization` | create a reproducible, accessible `ggplot2` chart | “Use `accessible-visualization` to make an accessible chart of sales by region.” |
| `quarto-report-generation` | create a concise, accessible HTML report from an analysis | “Use `quarto-report-generation` to turn this analysis into a report for leadership.” |

The skill instructions live in [`.posit/assistant/skills/`](.posit/assistant/skills/). You can use a single skill for a focused task, or use the full sequence for a finished report. The report skill incorporates the other three skills and pauses for your decisions about the question, calculations, story, visuals, and final draft.

At present, `quarto-report-generation` is the only included skill with built-in user checkpoints. To make another skill collaborative in the same way, replicate its checkpoint pattern: pause at decisions that affect the question, method, interpretation, or final output; present the relevant context and choices; then continue only after the user has confirmed, revised, or delegated the decision.

## Customize for your project

Edit a skill’s `SKILL.md` when your project needs a different data source, reporting standard, terminology, or output location. Keep each skill focused on one reusable job, and commit changes alongside the code or data process they govern.

The included helper scripts are located with their corresponding skills:

- [`accessible_palette.R`](.posit/assistant/skills/accessible-visualization/scripts/accessible_palette.R) selects data-aware, accessible palettes and supports literal color categories.
- [`metrics_helpers.R`](.posit/assistant/skills/analytics-metrics/scripts/metrics_helpers.R) provides common metric and data-quality helpers.
