###############################################################################
# 05_figures.R
# Publication-quality figures for PDMP must-access mandate DiD paper
#
# Inputs:  ../data/analysis_panel.rds
#          ../data/att_dynamic_log_emp.rds
#          ../data/att_dynamic_unemp.rds
#          ../data/att_dynamic_emp_rate.rds
#          ../data/pdmp_mandate_dates.rds
#
# Outputs: ../figures/fig_treatment_rollout.pdf
#          ../figures/fig_cohort_trends.pdf
#          ../figures/fig_event_study_main.pdf
#          ../figures/fig_event_study_panel.pdf
###############################################################################

# --- Packages ---------------------------------------------------------------
library(tidyverse)
library(ggplot2)
library(patchwork)
library(scales)

# --- Paths ------------------------------------------------------------------
data_dir <- here::here("output", "paper_109", "data")
fig_dir  <- here::here("output", "paper_109", "figures")

# Fallback: use relative paths if here() doesn't resolve correctly
if (!dir.exists(data_dir)) {
  data_dir <- "../data"
  fig_dir  <- "../figures"
}

dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# --- APEP theme & palette ---------------------------------------------------
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor   = element_blank(),
      panel.grid.major   = element_line(color = "grey90", linewidth = 0.3),
      axis.line          = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks         = element_line(color = "grey30", linewidth = 0.3),
      axis.title         = element_text(size = 11, face = "bold"),
      axis.text          = element_text(size = 10, color = "grey30"),
      legend.position    = "bottom",
      legend.title       = element_text(size = 10, face = "bold"),
      legend.text        = element_text(size = 9),
      plot.title         = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle      = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption       = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin        = margin(10, 15, 10, 10)
    )
}

apep_colors <- c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9")

# --- Load data --------------------------------------------------------------
panel   <- readRDS(file.path(data_dir, "analysis_panel.rds"))
mandate <- readRDS(file.path(data_dir, "pdmp_mandate_dates.rds"))

att_dyn_log_emp  <- readRDS(file.path(data_dir, "att_dynamic_log_emp.rds"))
att_dyn_unemp    <- readRDS(file.path(data_dir, "att_dynamic_unemp.rds"))
att_dyn_emp_rate <- readRDS(file.path(data_dir, "att_dynamic_emp_rate.rds"))

###############################################################################
# FIGURE 1: Treatment Adoption Rollout
###############################################################################

# Keep only states that adopted a mandate (year > 0)
rollout_df <- mandate %>%
  filter(mandate_year_full_exposure > 0) %>%
  arrange(mandate_year_full_exposure, state_abbr) %>%
  mutate(
    state_abbr = factor(state_abbr, levels = rev(state_abbr)),
    end_year   = 2023
  )

fig_rollout <- ggplot(rollout_df) +

  geom_segment(
    aes(
      x    = mandate_year_full_exposure,
      xend = end_year,
      y    = state_abbr,
      yend = state_abbr
    ),
    linewidth = 3.5,
    color     = apep_colors[1],
    alpha     = 0.75
  ) +
  geom_point(
    aes(x = mandate_year_full_exposure, y = state_abbr),
    size  = 2,
    color = apep_colors[2],
    shape = 16
  ) +
  scale_x_continuous(
    breaks = seq(2012, 2023, by = 1),
    limits = c(2012, 2023.5),
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  labs(
    title    = "Staggered Adoption of PDMP Must-Access Mandates",
    subtitle = "Year of full mandate exposure through 2023",
    x        = "Year",
    y        = NULL,
    caption  = "Note: Dot marks the first full year of mandate exposure. Bar extends to 2023."
  ) +
  theme_apep() +
  theme(
    axis.text.y    = element_text(size = 7, family = "mono"),
    panel.grid.major.y = element_blank(),
    legend.position = "none"
  )

ggsave(
  filename = file.path(fig_dir, "fig_treatment_rollout.pdf"),
  plot     = fig_rollout,
  width    = 8, height = 8, device = cairo_pdf
)
cat("Saved: fig_treatment_rollout.pdf\n")

###############################################################################
# FIGURE 2: Cohort Trends in Log Employment
###############################################################################

# Define cohort ordering for factor levels
cohort_levels <- c(
  "Early (2013-14)", "Middle (2015-16)", "Late (2017-18)",
  "Very Late (2019+)", "Never Treated"
)

cohort_means <- panel %>%
  filter(!is.na(cohort_group), !is.na(log_emp)) %>%
  mutate(cohort_group = factor(cohort_group, levels = cohort_levels)) %>%
  group_by(cohort_group, year) %>%
  summarise(
    mean_log_emp = mean(log_emp, na.rm = TRUE),
    n_states     = n_distinct(statefip),
    .groups      = "drop"
  )

# Identify the earliest adoption year for a vertical reference band
earliest_treat <- min(panel$first_treat[panel$first_treat > 0])

fig_cohort <- ggplot(
  cohort_means,
  aes(x = year, y = mean_log_emp, color = cohort_group, shape = cohort_group)
) +
  annotate(
    "rect",
    xmin = earliest_treat - 0.5, xmax = Inf,
    ymin = -Inf, ymax = Inf,
    fill = "grey90", alpha = 0.4
  ) +
  annotate(
    "text",
    x = earliest_treat + 0.2, y = Inf,
    label = "Treatment\nperiod begins",
    hjust = 0, vjust = 1.3, size = 3, color = "grey50", fontface = "italic"
  ) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  scale_color_manual(
    values = c(
      "Early (2013-14)"   = apep_colors[1],
      "Middle (2015-16)"  = apep_colors[2],
      "Late (2017-18)"    = apep_colors[3],
      "Very Late (2019+)" = apep_colors[4],
      "Never Treated"     = "grey50"
    )
  ) +
  scale_shape_manual(
    values = c(16, 17, 15, 18, 4)
  ) +
  scale_x_continuous(breaks = seq(2007, 2023, by = 2)) +
  labs(
    title    = "Mean Log Employment by Treatment Cohort",
    subtitle = "State-level averages; shaded region indicates post-treatment for earliest cohort",
    x        = "Year",
    y        = "Mean Log(Employment)",
    color    = "Cohort",
    shape    = "Cohort",
    caption  = "Note: Parallel pre-trends support common trends assumption."
  ) +
  theme_apep() +
  theme(
    legend.position = "bottom",
    legend.box      = "horizontal"
  ) +
  guides(
    color = guide_legend(nrow = 2, byrow = TRUE),
    shape = guide_legend(nrow = 2, byrow = TRUE)
  )

ggsave(
  filename = file.path(fig_dir, "fig_cohort_trends.pdf"),
  plot     = fig_cohort,
  width    = 8, height = 5, device = cairo_pdf
)
cat("Saved: fig_cohort_trends.pdf\n")

###############################################################################
# FIGURE 3: Main Event Study -- Log Employment
###############################################################################

# Helper: extract event-study data from an AGGTEobj
extract_es <- function(aggte_obj, outcome_label = "") {
  tibble(
    event_time = aggte_obj$egt,
    att        = aggte_obj$att.egt,
    se         = aggte_obj$se.egt,
    crit_val   = aggte_obj$crit.val.egt
  ) %>%
    mutate(
      ci_lower = att - crit_val * se,
      ci_upper = att + crit_val * se,
      outcome  = outcome_label
    )
}

es_log_emp <- extract_es(att_dyn_log_emp, "Log Employment")

fig_es_main <- ggplot(es_log_emp, aes(x = event_time, y = att)) +
  # Confidence interval ribbon
  geom_ribbon(
    aes(ymin = ci_lower, ymax = ci_upper),
    fill  = apep_colors[1],
    alpha = 0.2
  ) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40", linewidth = 0.5) +
  # Point estimates
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_point(color = apep_colors[1], size = 2.5, shape = 16) +
  scale_x_continuous(
    breaks = seq(min(es_log_emp$event_time), max(es_log_emp$event_time), by = 1)
  ) +
  scale_y_continuous(labels = label_number(accuracy = 0.001)) +
  labs(
    title    = "Dynamic Treatment Effects on Log Employment",
    subtitle = "Callaway & Sant'Anna (2021) event-study estimates with uniform 95% CI",
    x        = "Years Relative to Mandate Exposure",
    y        = "ATT (Log Points)",
    caption  = paste0(
      "Note: Estimates from CS-DiD aggregated to event time. ",
      "Uniform confidence bands account for simultaneous inference across all event times."
    )
  ) +
  theme_apep()

ggsave(
  filename = file.path(fig_dir, "fig_event_study_main.pdf"),
  plot     = fig_es_main,
  width    = 8, height = 5, device = cairo_pdf
)
cat("Saved: fig_event_study_main.pdf\n")

###############################################################################
# FIGURE 4: Event Study Panel -- (a) Log Employment, (b) Unemployment Rate
###############################################################################

make_es_panel <- function(aggte_obj, outcome_label, y_lab, color_idx = 1) {
  es_df <- extract_es(aggte_obj, outcome_label)

  ggplot(es_df, aes(x = event_time, y = att)) +
    geom_ribbon(
      aes(ymin = ci_lower, ymax = ci_upper),
      fill  = apep_colors[color_idx],
      alpha = 0.2
    ) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40", linewidth = 0.5) +
    geom_line(color = apep_colors[color_idx], linewidth = 0.7) +
    geom_point(color = apep_colors[color_idx], size = 2.5, shape = 16) +
    scale_x_continuous(
      breaks = seq(min(es_df$event_time), max(es_df$event_time), by = 1)
    ) +
    labs(
      title = outcome_label,
      x     = "Years Relative to Mandate Exposure",
      y     = y_lab
    ) +
    theme_apep()
}

p_log_emp <- make_es_panel(
  att_dyn_log_emp,
  "(a) Log Employment",
  "ATT (Log Points)",
  color_idx = 1
)

p_unemp <- make_es_panel(
  att_dyn_unemp,
  "(b) Unemployment Rate",
  "ATT (Percentage Points)",
  color_idx = 2
)

fig_es_panel <- p_log_emp / p_unemp +
  plot_annotation(
    title    = "Dynamic Treatment Effects of PDMP Must-Access Mandates",
    subtitle = "Callaway & Sant'Anna (2021) estimates with uniform 95% confidence intervals",
    caption  = "Note: Event time 0 = first full year of mandate exposure. Dashed line = zero effect. Dotted line = treatment onset.",
    theme    = theme(
      plot.title    = element_text(size = 14, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption  = element_text(size = 8, color = "grey50", hjust = 1)
    )
  )

ggsave(
  filename = file.path(fig_dir, "fig_event_study_panel.pdf"),
  plot     = fig_es_panel,
  width    = 8, height = 8, device = cairo_pdf
)
cat("Saved: fig_event_study_panel.pdf\n")

cat("\n--- All figures generated successfully ---\n")
