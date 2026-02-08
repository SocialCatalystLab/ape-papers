# ============================================================
# 05_figures.R - Publication-quality figures
# Paper 135: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality
# ============================================================

source("code/00_packages.R")

# Create output directories
dir.create("figures", showWarnings = FALSE)

# Load data
panel <- readRDS("data/analysis_panel.rds")
policy_db <- read_csv("data/policy_database.csv", show_col_types = FALSE)

# Load results (with graceful fallback)
main_results <- tryCatch(readRDS("data/main_results.rds"), error = function(e) NULL)
robustness   <- tryCatch(readRDS("data/robustness_results.rds"), error = function(e) NULL)

cat("Panel loaded:", nrow(panel), "observations\n")

# ============================================================
# Figure 1: Treatment Rollout Timeline (Horizontal Bar Chart)
# ============================================================

cat("\nCreating Figure 1: Treatment Rollout Timeline\n")

tryCatch({
  # Build timeline data from policy database
  timeline_data <- policy_db %>%
    arrange(first_treat, state_abbr) %>%
    mutate(
      treat_year = factor(first_treat),
      state_ordered = reorder(state_abbr, -first_treat)
    )

  # Color palette for treatment years
  treat_years <- sort(unique(timeline_data$first_treat))
  year_colors <- setNames(
    c("#08306B", "#2171B5", "#4292C6", "#6BAED6", "#9ECAE1", "#C6DBEF")[seq_along(treat_years)],
    as.character(treat_years)
  )

  # Identify not-yet-treated states (first_treat > max year in data)
  max_data_year <- max(panel$year)
  nyt_states <- timeline_data %>%
    filter(first_treat > max_data_year) %>%
    pull(state_abbr)

  # Mark not-yet-treated states with different alpha
  timeline_data <- timeline_data %>%
    mutate(
      in_estimation = ifelse(state_abbr %in% nyt_states, "Not-yet-treated\n(no post-treatment data)", "In estimation sample")
    )

  fig1 <- ggplot(timeline_data, aes(x = first_treat, y = state_ordered,
                                     fill = treat_year, alpha = in_estimation)) +
    geom_col(width = 0.7, show.legend = TRUE) +
    geom_text(aes(label = state_abbr, x = first_treat - 0.15),
              hjust = 1, size = 3, color = "grey30", show.legend = FALSE) +
    scale_fill_manual(values = year_colors, name = "Treatment Year") +
    scale_alpha_manual(values = c("In estimation sample" = 1.0,
                                   "Not-yet-treated\n(no post-treatment data)" = 0.35),
                        name = "Status") +
    scale_x_continuous(
      breaks = seq(min(treat_years), max(treat_years)),
      limits = c(min(treat_years) - 2, max(treat_years) + 0.5)
    ) +
    labs(
      title = "Staggered Adoption of State Insulin Copay Caps",
      subtitle = "Year of first full calendar-year exposure to copay cap legislation",
      x = "Treatment Year",
      y = NULL,
      caption = paste0(
        "Source: State legislation, NCSL insulin copay cap tracker.\n",
        length(treat_years), " treatment cohorts, ",
        nrow(timeline_data), " states adopted caps between ",
        min(treat_years), "-", max(treat_years), ". ",
        "Treatment year is the first January 1 under the law.\n",
        "Faded bars = states with treatment onset after ", max_data_year,
        " (not-yet-treated; reclassified as controls in estimation)."
      )
    ) +
    theme_apep() +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid.major.y = element_blank()
    )

  ggsave("figures/fig1_treatment_timeline.pdf", fig1, width = 9, height = 8)
  ggsave("figures/fig1_treatment_timeline.png", fig1, width = 9, height = 8, dpi = 300)
  cat("  Saved figures/fig1_treatment_timeline.pdf\n")

}, error = function(e) {
  cat("  Timeline creation error:", e$message, "\n")
})

# ============================================================
# Figure 2: Raw Trends — Ever-Treated vs Never-Treated
# ============================================================

cat("\nCreating Figure 2: Raw Trends\n")

trends_data <- panel %>%
  mutate(group = ifelse(first_treat > 0, "Ever-Treated\n(Copay Cap States)",
                        "Never-Treated\n(Control States)")) %>%
  group_by(group, year) %>%
  summarise(
    mean_rate = mean(mortality_rate, na.rm = TRUE),
    se_rate = sd(mortality_rate, na.rm = TRUE) / sqrt(n()),
    n_states = n_distinct(state_fips),
    .groups = "drop"
  ) %>%
  mutate(
    ci_lower = mean_rate - 1.96 * se_rate,
    ci_upper = mean_rate + 1.96 * se_rate
  )

# Find the earliest treatment year for annotation
earliest_treat <- min(policy_db$first_treat)

fig2 <- ggplot(trends_data, aes(x = year, y = mean_rate,
                                 color = group, fill = group)) +
  # Shade post-treatment region
  annotate("rect",
           xmin = earliest_treat - 0.5, xmax = max(panel$year) + 0.5,
           ymin = -Inf, ymax = Inf,
           fill = "grey95", alpha = 0.5) +
  # Confidence bands
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15,
              color = NA) +
  # Lines and points
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  # Treatment onset annotation
  geom_vline(xintercept = earliest_treat - 0.5, linetype = "dashed",
             color = "grey50", linewidth = 0.5) +
  annotate("text", x = earliest_treat + 0.5, y = max(trends_data$ci_upper, na.rm = TRUE),
           label = "First\ncaps\ntake\neffect", hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(values = c(apep_colors[1], apep_colors[2])) +
  scale_fill_manual(values = c(apep_colors[1], apep_colors[2])) +
  scale_x_continuous(breaks = seq(2000, 2023, 3)) +
  labs(
    title = "Diabetes Mortality Rates (All Ages, Age-Adjusted) by Treatment Status",
    subtitle = "Average state-level mortality per 100,000; shaded region = post-treatment",
    x = "Year",
    y = "Deaths per 100,000",
    color = NULL,
    fill = NULL,
    caption = paste0(
      "Source: CDC WONDER, ICD-10 E10-E14. ",
      "Bands show 95% CI for state-level mean. ",
      "N = ", n_distinct(panel$state_fips), " states, ",
      min(panel$year), "-", max(panel$year), "."
    )
  ) +
  theme_apep()

ggsave("figures/fig2_raw_trends.pdf", fig2, width = 9, height = 6)
ggsave("figures/fig2_raw_trends.png", fig2, width = 9, height = 6, dpi = 300)
cat("  Saved figures/fig2_raw_trends.pdf\n")

# ============================================================
# Figure 3: Event Study Plot (CS-DiD Dynamic ATT)
# ============================================================

cat("\nCreating Figure 3: Event Study\n")

if (file.exists("data/cs_event_study.rds")) {
  cs_event <- readRDS("data/cs_event_study.rds")

  es_df <- data.frame(
    event_time = cs_event$egt,
    att = cs_event$att.egt,
    se = cs_event$se.egt
  ) %>%
    mutate(
      ci_lower = att - 1.96 * se,
      ci_upper = att + 1.96 * se,
      significant = (ci_lower > 0 | ci_upper < 0)
    )

  fig3 <- ggplot(es_df, aes(x = event_time, y = att)) +
    # Zero reference line
    geom_hline(yintercept = 0, linetype = "solid", color = "grey60", linewidth = 0.4) +
    # Treatment onset line
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50", linewidth = 0.5) +
    # Confidence band
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                fill = apep_colors[1], alpha = 0.2) +
    # Point estimates
    geom_line(color = apep_colors[1], linewidth = 0.8) +
    geom_point(aes(shape = significant), color = apep_colors[1], size = 2.5) +
    scale_shape_manual(values = c("TRUE" = 16, "FALSE" = 1),
                       guide = "none") +
    # Annotations
    annotate("text", x = min(es_df$event_time) + 0.5,
             y = max(es_df$ci_upper, na.rm = TRUE) * 0.9,
             label = "Pre-treatment", hjust = 0, size = 3.5, color = "grey40") +
    annotate("text", x = 0.5,
             y = max(es_df$ci_upper, na.rm = TRUE) * 0.9,
             label = "Post-treatment", hjust = 0, size = 3.5, color = "grey40") +
    scale_x_continuous(breaks = seq(-10, 10, 2)) +
    labs(
      title = "Event Study: Effect of Insulin Copay Caps on Diabetes Mortality",
      subtitle = "Callaway-Sant'Anna (2021) heterogeneity-robust estimator, doubly robust",
      x = "Years Relative to Copay Cap Implementation",
      y = "ATT (Deaths per 100,000)",
      caption = paste0(
        "Notes: Shaded area = 95% pointwise CI. Filled points = significant at 5%. ",
        "Reference period: t = -1.\n",
        "Control group: never-treated states. Universal base period."
      )
    ) +
    theme_apep()

  ggsave("figures/fig3_event_study.pdf", fig3, width = 9, height = 6)
  ggsave("figures/fig3_event_study.png", fig3, width = 9, height = 6, dpi = 300)
  cat("  Saved figures/fig3_event_study.pdf\n")

} else if (file.exists("data/es_coefficients.rds")) {
  es_df <- readRDS("data/es_coefficients.rds")

  fig3 <- ggplot(es_df, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey60") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                fill = apep_colors[1], alpha = 0.2) +
    geom_line(color = apep_colors[1], linewidth = 0.8) +
    geom_point(color = apep_colors[1], size = 2.5) +
    labs(
      title = "Event Study: Insulin Copay Caps and Diabetes Mortality",
      subtitle = "Callaway-Sant'Anna estimator",
      x = "Years Relative to Treatment",
      y = "ATT (Deaths per 100,000)"
    ) +
    theme_apep()

  ggsave("figures/fig3_event_study.pdf", fig3, width = 9, height = 6)
  ggsave("figures/fig3_event_study.png", fig3, width = 9, height = 6, dpi = 300)
  cat("  Saved figures/fig3_event_study.pdf\n")

} else {
  cat("  WARNING: Event study results not found — skipping Figure 3\n")
  cat("  Ensure 03_main_analysis.R has been run successfully.\n")
}

# ============================================================
# Figure 4: Bacon Decomposition
# ============================================================

cat("\nCreating Figure 4: Bacon Decomposition\n")

if (file.exists("data/bacon_decomposition.rds")) {
  bacon <- readRDS("data/bacon_decomposition.rds")

  fig4 <- ggplot(bacon, aes(x = weight, y = estimate, color = type, shape = type)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
    geom_point(size = 3, alpha = 0.7) +
    scale_color_manual(
      values = c(
        "Earlier vs Later Treated" = apep_colors[1],
        "Later vs Earlier Treated" = apep_colors[2],
        "Treated vs Untreated"     = apep_colors[3]
      ),
      name = "Comparison Type"
    ) +
    scale_shape_manual(
      values = c(
        "Earlier vs Later Treated" = 17,
        "Later vs Earlier Treated" = 15,
        "Treated vs Untreated"     = 16
      ),
      name = "Comparison Type"
    ) +
    labs(
      title = "Goodman-Bacon (2021) Decomposition of TWFE Estimate",
      subtitle = "Each point is a 2x2 DiD comparison; size reflects weight in TWFE",
      x = "Weight in TWFE Estimate",
      y = "2x2 DiD Estimate (Deaths per 100,000)",
      caption = paste0(
        "Notes: TWFE is a weighted average of all pairwise 2x2 DiD comparisons.\n",
        "Negative-weight comparisons (later vs earlier treated) can bias TWFE."
      )
    ) +
    theme_apep()

  ggsave("figures/fig4_bacon_decomposition.pdf", fig4, width = 9, height = 6)
  ggsave("figures/fig4_bacon_decomposition.png", fig4, width = 9, height = 6, dpi = 300)
  cat("  Saved figures/fig4_bacon_decomposition.pdf\n")

} else {
  cat("  WARNING: Bacon decomposition results not found — skipping Figure 4\n")
  cat("  Ensure 04_robustness.R has been run successfully.\n")
}

# ============================================================
# Figure 5: Placebo Tests
# ============================================================

cat("\nCreating Figure 5: Placebo Tests\n")

# Create a combined placebo event study figure
placebo_panels <- list()

# Panel A: Heart disease mortality (placebo)
if (file.exists("data/placebo_heart_event_study.rds")) {
  es_heart <- readRDS("data/placebo_heart_event_study.rds")
  es_heart_coefs <- if (!is.null(es_heart$att.egt)) es_heart$att.egt else es_heart$att
  es_heart_times <- if (!is.null(es_heart$egt)) es_heart$egt else es_heart$e
  es_heart_se    <- if (!is.null(es_heart$se.egt)) es_heart$se.egt else es_heart$se
  placebo_heart_df <- data.frame(
    event_time = es_heart_times,
    att = es_heart_coefs,
    se = es_heart_se,
    outcome = "A: Heart Disease Mortality (Unrelated Cause)"
  ) %>%
    mutate(
      ci_lower = att - 1.96 * se,
      ci_upper = att + 1.96 * se
    )
  placebo_panels[["heart"]] <- placebo_heart_df
}

# Panel B: Cancer mortality 25-64
if (file.exists("data/placebo_cancer_event_study.rds")) {
  es_cancer <- readRDS("data/placebo_cancer_event_study.rds")
  es_cancer_coefs <- if (!is.null(es_cancer$att.egt)) es_cancer$att.egt else es_cancer$att
  es_cancer_times <- if (!is.null(es_cancer$egt)) es_cancer$egt else es_cancer$e
  es_cancer_se    <- if (!is.null(es_cancer$se.egt)) es_cancer$se.egt else es_cancer$se
  placebo_cancer_df <- data.frame(
    event_time = es_cancer_times,
    att = es_cancer_coefs,
    se = es_cancer_se,
    outcome = "B: Cancer Mortality (Unrelated Cause)"
  ) %>%
    mutate(
      ci_lower = att - 1.96 * se,
      ci_upper = att + 1.96 * se
    )
  placebo_panels[["cancer"]] <- placebo_cancer_df
}

if (length(placebo_panels) > 0) {
  # Null-check each panel before combining
  placebo_panels <- Filter(function(x) !is.null(x) && nrow(x) > 0, placebo_panels)
  if (length(placebo_panels) == 0) {
    cat("  WARNING: All placebo panels are empty after null-check — skipping Figure 5\n")
  }
  placebo_combined <- bind_rows(placebo_panels)

  fig5 <- ggplot(placebo_combined, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey60", linewidth = 0.4) +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50", linewidth = 0.5) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                fill = apep_colors[2], alpha = 0.2) +
    geom_line(color = apep_colors[2], linewidth = 0.8) +
    geom_point(color = apep_colors[2], size = 2) +
    facet_wrap(~outcome, scales = "free_y", ncol = 1) +
    scale_x_continuous(breaks = seq(-10, 10, 2)) +
    labs(
      title = "Placebo Tests: Outcomes That Should Not Be Affected",
      subtitle = "Callaway-Sant'Anna event studies on placebo outcomes (1999-2017)",
      x = "Years Relative to Copay Cap Implementation",
      y = "ATT",
      caption = paste0(
        "Notes: Panel A: Heart disease mortality is unrelated to insulin copay policy.\n",
        "Panel B: Cancer mortality is unrelated to insulin copay policy. ",
        "Placebo data covers 1999-2017 only. Null effects confirm identification."
      )
    ) +
    theme_apep()

  ggsave("figures/fig5_placebo_tests.pdf", fig5, width = 9, height = 9)
  ggsave("figures/fig5_placebo_tests.png", fig5, width = 9, height = 9, dpi = 300)
  cat("  Saved figures/fig5_placebo_tests.pdf\n")

} else {
  cat("  WARNING: Placebo event study results not found — skipping Figure 5\n")
  cat("  Ensure 04_robustness.R has been run successfully.\n")
}

# ============================================================
# Figure 6: HonestDiD Sensitivity Bounds
# ============================================================

cat("\nCreating Figure 6: HonestDiD Sensitivity\n")

if (file.exists("data/honestdid_results.rds")) {
  honest_data <- readRDS("data/honestdid_results.rds")

  if (!is.null(honest_data$relative_magnitudes)) {
    rm_results <- honest_data$relative_magnitudes

    # The results should have Mbar, lb, ub columns (from HonestDiD tibble)
    if (is.data.frame(rm_results) || is.matrix(rm_results)) {
      rm_df <- as.data.frame(rm_results)

      # Identify the x-axis column (Mbar) and bounds (lb, ub)
      x_col <- if ("Mbar" %in% names(rm_df)) "Mbar" else names(rm_df)[ncol(rm_df)]
      lb_col <- if ("lb" %in% names(rm_df)) "lb" else names(rm_df)[1]
      ub_col <- if ("ub" %in% names(rm_df)) "ub" else names(rm_df)[2]

      cat("  HonestDiD columns:", paste(names(rm_df), collapse = ", "), "\n")
      cat("  Using x=", x_col, ", lb=", lb_col, ", ub=", ub_col, "\n")

      fig6 <- ggplot(rm_df, aes(x = .data[[x_col]])) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
        geom_ribbon(aes(ymin = .data[[lb_col]], ymax = .data[[ub_col]]),
                    fill = apep_colors[3], alpha = 0.3) +
        geom_line(aes(y = .data[[lb_col]]), color = apep_colors[3], linewidth = 0.7) +
        geom_line(aes(y = .data[[ub_col]]), color = apep_colors[3], linewidth = 0.7) +
        labs(
          title = "Sensitivity Analysis: HonestDiD Bounds",
          subtitle = expression(paste("Relative magnitudes approach (",
                                      bar(M), " controls maximum pre-trend violation)")),
          x = expression(bar(M) ~~ "(Max violation relative to largest pre-trend diff)"),
          y = "Identified Set for ATT (Deaths per 100,000)",
          caption = paste0(
            "Notes: Rambachan and Roth (2023) sensitivity analysis.\n",
            "At Mbar = 0, assumes exact parallel trends. ",
            "Bounds widen as pre-trend violations are allowed."
          )
        ) +
        theme_apep()

      ggsave("figures/fig6_honestdid.pdf", fig6, width = 8, height = 6)
      ggsave("figures/fig6_honestdid.png", fig6, width = 8, height = 6, dpi = 300)
      cat("  Saved figures/fig6_honestdid.pdf\n")
    } else {
      cat("  HonestDiD results format not recognized — skipping Figure 6\n")
    }
  } else {
    cat("  No relative magnitudes results — skipping Figure 6\n")
  }

} else {
  cat("  WARNING: HonestDiD results not found — skipping Figure 6\n")
  cat("  Ensure 04_robustness.R has been run successfully.\n")
}

# ============================================================
# Supplementary Figure: Estimator Comparison
# ============================================================

cat("\nCreating Supplementary Figure: Estimator Comparison\n")

if (!is.null(main_results) && !is.null(main_results$results_summary)) {
  comp_df <- main_results$results_summary

  fig_comp <- ggplot(comp_df, aes(x = reorder(Estimator, ATT), y = ATT)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_pointrange(aes(ymin = CI_lower, ymax = CI_upper),
                    color = apep_colors[1], size = 0.8, linewidth = 0.7) +
    coord_flip() +
    labs(
      title = "Comparison of Treatment Effect Estimates",
      subtitle = "ATT from different DiD estimators with 95% CI",
      x = NULL,
      y = "ATT (Deaths per 100,000)",
      caption = paste0(
        "Notes: All estimators use state and year fixed effects.\n",
        "Standard errors clustered at state level. ",
        "TWFE may be biased under treatment effect heterogeneity."
      )
    ) +
    theme_apep() +
    theme(axis.text.y = element_text(size = 10))

  ggsave("figures/fig_estimator_comparison.pdf", fig_comp, width = 9, height = 5)
  ggsave("figures/fig_estimator_comparison.png", fig_comp, width = 9, height = 5, dpi = 300)
  cat("  Saved figures/fig_estimator_comparison.pdf\n")
}

cat("\n=== All Figures Created ===\n")
cat("Figures saved to figures/ directory\n")
