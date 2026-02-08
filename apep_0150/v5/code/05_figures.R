# ============================================================
# 05_figures.R - Publication-quality figures
# Paper 148: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality (v5)
# Revision of apep_0161 (family apep_0150)
# ============================================================
# PROVENANCE:
#   Inputs:
#     data/analysis_panel.rds        (from 02_clean_data.R, PRIMARY working-age)
#     data/analysis_panel_allages.rds (from 02_clean_data.R, SECONDARY all-ages)
#     data/policy_database.csv       (from 01_fetch_data.R)
#     data/main_results.rds          (from 03_main_analysis.R)
#     data/robustness_results.rds    (from 04_robustness.R)
#     data/cs_event_study.rds        (from 03_main_analysis.R)
#     data/cs_event_study_allages.rds (from 03_main_analysis.R)
#     data/bacon_decomposition.rds   (from 04_robustness.R)
#     data/honestdid_results.rds     (from 04_robustness.R)
#   Outputs:
#     figures/fig1_treatment_timeline.pdf
#     figures/fig2_raw_trends.pdf         (PRIMARY: working-age)
#     figures/fig3_event_study.pdf         (PRIMARY: working-age CS-DiD)
#     figures/fig4_bacon_decomposition.pdf
#     figures/fig5_placebo_tests.pdf
#     figures/fig6_honestdid.pdf           (TWO-PANEL: RM + smoothness)
#     figures/fig_estimator_comparison.pdf
#     figures/figA_raw_trends_allages.pdf  (APPENDIX: all-ages)
#     figures/figA_event_study_allages.pdf (APPENDIX: all-ages)
# ============================================================

source("code/00_packages.R")

dir.create("figures", showWarnings = FALSE)

# Load data
panel <- readRDS("data/analysis_panel.rds")
policy_db <- read_csv("data/policy_database.csv", show_col_types = FALSE)

# Load results
main_results <- tryCatch(readRDS("data/main_results.rds"), error = function(e) NULL)
robustness   <- tryCatch(readRDS("data/robustness_results.rds"), error = function(e) NULL)

cat("Panel loaded:", nrow(panel), "observations (working-age 25-64)\n")

# ============================================================
# Figure 1: Treatment Rollout Timeline (Horizontal Bar Chart)
# ============================================================

cat("\nCreating Figure 1: Treatment Rollout Timeline\n")

tryCatch({
  timeline_data <- policy_db %>%
    arrange(first_treat, state_abbr) %>%
    mutate(
      treat_year = factor(first_treat),
      state_ordered = reorder(state_abbr, -first_treat)
    )

  treat_years <- sort(unique(timeline_data$first_treat))
  year_colors <- setNames(
    c("#08306B", "#2171B5", "#4292C6", "#6BAED6", "#9ECAE1", "#C6DBEF")[seq_along(treat_years)],
    as.character(treat_years)
  )

  max_data_year <- max(panel$year)
  nyt_states <- timeline_data %>%
    filter(first_treat > max_data_year) %>%
    pull(state_abbr)

  timeline_data <- timeline_data %>%
    mutate(
      in_estimation = ifelse(state_abbr %in% nyt_states,
                             "Not-yet-treated\n(no post-treatment data)",
                             "In estimation sample")
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
        " (not-yet-treated; reclassified as controls in estimation).\n",
        "Vermont excluded from primary analysis due to suppressed post-treatment mortality data."
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
# Figure 2: Raw Trends — Working-Age (25-64) PRIMARY
# ============================================================

cat("\nCreating Figure 2: Raw Trends (Working-Age 25-64)\n")

trends_data <- panel %>%
  mutate(group = ifelse(first_treat > 0, "Ever-Treated\n(Copay Cap States)",
                        "Never-Treated\n(Control States)")) %>%
  group_by(group, year) %>%
  summarise(
    mean_rate = mean(mortality_rate, na.rm = TRUE),
    se_rate = sd(mortality_rate, na.rm = TRUE) / sqrt(sum(!is.na(mortality_rate))),
    n_states = n_distinct(state_fips),
    .groups = "drop"
  ) %>%
  mutate(
    ci_lower = mean_rate - 1.96 * se_rate,
    ci_upper = mean_rate + 1.96 * se_rate
  )

earliest_treat <- min(policy_db$first_treat)

fig2 <- ggplot(trends_data, aes(x = year, y = mean_rate,
                                 color = group, fill = group)) +
  annotate("rect",
           xmin = earliest_treat - 0.5, xmax = max(panel$year) + 0.5,
           ymin = -Inf, ymax = Inf,
           fill = "grey95", alpha = 0.5) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15,
              color = NA) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  geom_vline(xintercept = earliest_treat - 0.5, linetype = "dashed",
             color = "grey50", linewidth = 0.5) +
  annotate("text", x = earliest_treat + 0.5, y = max(trends_data$ci_upper, na.rm = TRUE),
           label = "First\ncaps\ntake\neffect", hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(values = c(apep_colors[1], apep_colors[2])) +
  scale_fill_manual(values = c(apep_colors[1], apep_colors[2])) +
  scale_x_continuous(breaks = seq(2000, 2023, 3)) +
  labs(
    title = "Working-Age (25-64) Diabetes Mortality by Treatment Status",
    subtitle = "Average state-level mortality per 100,000; shaded region = post-treatment",
    x = "Year",
    y = "Deaths per 100,000 (Ages 25-64)",
    color = NULL,
    fill = NULL,
    caption = paste0(
      "Source: CDC WONDER ICD-10 E10-E14, ages 25-64. ",
      "Bands show 95% CI for state-level mean. ",
      "N = ", n_distinct(panel$state_fips), " states, ",
      min(panel$year), "-", max(panel$year), ".\n",
      "Vermont excluded from primary analysis."
    )
  ) +
  theme_apep()

ggsave("figures/fig2_raw_trends.pdf", fig2, width = 9, height = 6)
ggsave("figures/fig2_raw_trends.png", fig2, width = 9, height = 6, dpi = 300)
cat("  Saved figures/fig2_raw_trends.pdf\n")

# ============================================================
# Figure 3: Event Study Plot — Working-Age (CS-DiD) PRIMARY
# ============================================================

cat("\nCreating Figure 3: Event Study (Working-Age)\n")

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
    geom_hline(yintercept = 0, linetype = "solid", color = "grey60", linewidth = 0.4) +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50", linewidth = 0.5) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                fill = apep_colors[1], alpha = 0.2) +
    geom_line(color = apep_colors[1], linewidth = 0.8) +
    geom_point(aes(shape = significant), color = apep_colors[1], size = 2.5) +
    scale_shape_manual(values = c("TRUE" = 16, "FALSE" = 1),
                       guide = "none") +
    annotate("text", x = min(es_df$event_time) + 0.5,
             y = max(es_df$ci_upper, na.rm = TRUE) * 0.9,
             label = "Pre-treatment", hjust = 0, size = 3.5, color = "grey40") +
    annotate("text", x = 0.5,
             y = max(es_df$ci_upper, na.rm = TRUE) * 0.9,
             label = "Post-treatment", hjust = 0, size = 3.5, color = "grey40") +
    scale_x_continuous(breaks = seq(-10, 10, 2)) +
    labs(
      title = "Event Study: Insulin Copay Caps and Working-Age Diabetes Mortality",
      subtitle = "Callaway-Sant'Anna (2021), ages 25-64, doubly robust",
      x = "Years Relative to Copay Cap Implementation",
      y = "ATT (Deaths per 100,000, Ages 25-64)",
      caption = paste0(
        "Notes: Shaded area = 95% pointwise CI. Filled points = significant at 5%. ",
        "Reference period: t = -1.\n",
        "Control group: never-treated states. Universal base period. Vermont excluded."
      )
    ) +
    theme_apep()

  ggsave("figures/fig3_event_study.pdf", fig3, width = 9, height = 6)
  ggsave("figures/fig3_event_study.png", fig3, width = 9, height = 6, dpi = 300)
  cat("  Saved figures/fig3_event_study.pdf\n")

} else {
  cat("  WARNING: Event study results not found — skipping Figure 3\n")
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
      subtitle = "Working-age (25-64) diabetes mortality; each point is a 2x2 DiD comparison",
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
}

# ============================================================
# Figure 5: Placebo Tests
# ============================================================

cat("\nCreating Figure 5: Placebo Tests\n")

placebo_panels <- list()

heart_es_file <- if (file.exists("data/placebo_heart_event_study_full.rds")) {
  "data/placebo_heart_event_study_full.rds"
} else if (file.exists("data/placebo_heart_event_study.rds")) {
  "data/placebo_heart_event_study.rds"
} else { NULL }

heart_label_suffix <- if (file.exists("data/placebo_heart_event_study_full.rds")) {
  " (Full Panel)"
} else { " (Pre-Treatment Only)" }

if (!is.null(heart_es_file)) {
  es_heart <- readRDS(heart_es_file)
  placebo_heart_df <- data.frame(
    event_time = if (!is.null(es_heart$egt)) es_heart$egt else es_heart$e,
    att = if (!is.null(es_heart$att.egt)) es_heart$att.egt else es_heart$att,
    se = if (!is.null(es_heart$se.egt)) es_heart$se.egt else es_heart$se,
    outcome = paste0("A: Heart Disease Mortality", heart_label_suffix)
  ) %>%
    mutate(ci_lower = att - 1.96 * se, ci_upper = att + 1.96 * se)
  placebo_panels[["heart"]] <- placebo_heart_df
}

cancer_es_file <- if (file.exists("data/placebo_cancer_event_study_full.rds")) {
  "data/placebo_cancer_event_study_full.rds"
} else if (file.exists("data/placebo_cancer_event_study.rds")) {
  "data/placebo_cancer_event_study.rds"
} else { NULL }

cancer_label_suffix <- if (file.exists("data/placebo_cancer_event_study_full.rds")) {
  " (Full Panel)"
} else { " (Pre-Treatment Only)" }

if (!is.null(cancer_es_file)) {
  es_cancer <- readRDS(cancer_es_file)
  placebo_cancer_df <- data.frame(
    event_time = if (!is.null(es_cancer$egt)) es_cancer$egt else es_cancer$e,
    att = if (!is.null(es_cancer$att.egt)) es_cancer$att.egt else es_cancer$att,
    se = if (!is.null(es_cancer$se.egt)) es_cancer$se.egt else es_cancer$se,
    outcome = paste0("B: Cancer Mortality", cancer_label_suffix)
  ) %>%
    mutate(ci_lower = att - 1.96 * se, ci_upper = att + 1.96 * se)
  placebo_panels[["cancer"]] <- placebo_cancer_df
}

if (length(placebo_panels) > 0) {
  placebo_panels <- Filter(function(x) !is.null(x) && nrow(x) > 0, placebo_panels)
  if (length(placebo_panels) > 0) {
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
        subtitle = "Callaway-Sant'Anna event studies, working-age (25-64)",
        x = "Years Relative to Copay Cap Implementation",
        y = "ATT",
        caption = paste0(
          "Notes: Panel A: Heart disease mortality (unrelated to insulin policy).\n",
          "Panel B: Cancer mortality (unrelated). Null effects confirm identification."
        )
      ) +
      theme_apep()

    ggsave("figures/fig5_placebo_tests.pdf", fig5, width = 9, height = 9)
    ggsave("figures/fig5_placebo_tests.png", fig5, width = 9, height = 9, dpi = 300)
    cat("  Saved figures/fig5_placebo_tests.pdf\n")
  }
} else {
  cat("  WARNING: Placebo event study results not found — skipping Figure 5\n")
}

# ============================================================
# Figure 6: HonestDiD Sensitivity (TWO-PANEL: RM + Smoothness)
#   Flag 7 fix: show BOTH approaches
# ============================================================

cat("\nCreating Figure 6: HonestDiD Sensitivity (Two-Panel)\n")

if (file.exists("data/honestdid_results.rds")) {
  honest_data <- readRDS("data/honestdid_results.rds")

  panels_honest <- list()

  # Panel A: Relative Magnitudes
  if (!is.null(honest_data$relative_magnitudes)) {
    rm_df <- as.data.frame(honest_data$relative_magnitudes)
    x_col <- if ("Mbar" %in% names(rm_df)) "Mbar" else names(rm_df)[ncol(rm_df)]
    lb_col <- if ("lb" %in% names(rm_df)) "lb" else names(rm_df)[1]
    ub_col <- if ("ub" %in% names(rm_df)) "ub" else names(rm_df)[2]

    rm_plot_df <- data.frame(
      x = rm_df[[x_col]],
      lb = rm_df[[lb_col]],
      ub = rm_df[[ub_col]],
      panel = "A: Relative Magnitudes"
    )
    panels_honest[["rm"]] <- rm_plot_df
  }

  # Panel B: Smoothness/FLCI
  if (!is.null(honest_data$smoothness)) {
    sd_df <- as.data.frame(honest_data$smoothness)
    x_col_sd <- if ("M" %in% names(sd_df)) "M" else names(sd_df)[ncol(sd_df)]
    lb_col_sd <- if ("lb" %in% names(sd_df)) "lb" else names(sd_df)[1]
    ub_col_sd <- if ("ub" %in% names(sd_df)) "ub" else names(sd_df)[2]

    sd_plot_df <- data.frame(
      x = sd_df[[x_col_sd]],
      lb = sd_df[[lb_col_sd]],
      ub = sd_df[[ub_col_sd]],
      panel = "B: Smoothness (FLCI)"
    )
    panels_honest[["sd"]] <- sd_plot_df
  }

  if (length(panels_honest) > 0) {
    honest_combined <- bind_rows(panels_honest)

    fig6 <- ggplot(honest_combined, aes(x = x)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      geom_ribbon(aes(ymin = lb, ymax = ub),
                  fill = apep_colors[3], alpha = 0.3) +
      geom_line(aes(y = lb), color = apep_colors[3], linewidth = 0.7) +
      geom_line(aes(y = ub), color = apep_colors[3], linewidth = 0.7) +
      facet_wrap(~panel, scales = "free_x", ncol = 2) +
      labs(
        title = "HonestDiD Sensitivity Analysis: Two Approaches",
        subtitle = "Rambachan and Roth (2023), working-age (25-64) diabetes mortality",
        x = "Sensitivity Parameter",
        y = "Identified Set for ATT (Deaths per 100,000)",
        caption = paste0(
          "Notes: Panel A uses relative magnitudes (Mbar controls max pre-trend violation).\n",
          "Panel B uses smoothness restriction (Delta^SD with FLCI). ",
          "VCV method: ", honest_data$vcv_method, "."
        )
      ) +
      theme_apep()

    ggsave("figures/fig6_honestdid.pdf", fig6, width = 12, height = 6)
    ggsave("figures/fig6_honestdid.png", fig6, width = 12, height = 6, dpi = 300)
    cat("  Saved figures/fig6_honestdid.pdf\n")
  } else {
    cat("  No HonestDiD results to plot\n")
  }

} else {
  cat("  WARNING: HonestDiD results not found — skipping Figure 6\n")
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
      title = "Comparison of Treatment Effect Estimates (Working-Age 25-64)",
      subtitle = "ATT from different DiD estimators with 95% CI",
      x = NULL,
      y = "ATT (Deaths per 100,000, Ages 25-64)",
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

# ============================================================
# Appendix Figure A1: Raw Trends — All Ages
# ============================================================

cat("\nCreating Appendix Figure: Raw Trends (All Ages)\n")

if (file.exists("data/analysis_panel_allages.rds")) {
  panel_aa <- readRDS("data/analysis_panel_allages.rds")

  trends_aa <- panel_aa %>%
    mutate(group = ifelse(first_treat > 0, "Ever-Treated", "Never-Treated")) %>%
    group_by(group, year) %>%
    summarise(
      mean_rate = mean(mortality_rate, na.rm = TRUE),
      se_rate = sd(mortality_rate, na.rm = TRUE) / sqrt(sum(!is.na(mortality_rate))),
      .groups = "drop"
    ) %>%
    mutate(
      ci_lower = mean_rate - 1.96 * se_rate,
      ci_upper = mean_rate + 1.96 * se_rate
    )

  fig_aa <- ggplot(trends_aa, aes(x = year, y = mean_rate,
                                   color = group, fill = group)) +
    annotate("rect",
             xmin = earliest_treat - 0.5, xmax = max(panel_aa$year) + 0.5,
             ymin = -Inf, ymax = Inf, fill = "grey95", alpha = 0.5) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15, color = NA) +
    geom_line(linewidth = 0.9) +
    geom_point(size = 2) +
    geom_vline(xintercept = earliest_treat - 0.5, linetype = "dashed",
               color = "grey50", linewidth = 0.5) +
    scale_color_manual(values = c(apep_colors[1], apep_colors[2])) +
    scale_fill_manual(values = c(apep_colors[1], apep_colors[2])) +
    scale_x_continuous(breaks = seq(2000, 2023, 3)) +
    labs(
      title = "Diabetes Mortality Rates (All Ages, Age-Adjusted) by Treatment Status",
      subtitle = "Appendix: All-ages outcome for comparison with primary working-age results",
      x = "Year",
      y = "Deaths per 100,000 (All Ages)",
      color = NULL, fill = NULL,
      caption = "Source: CDC WONDER ICD-10 E10-E14, all ages, age-adjusted."
    ) +
    theme_apep()

  ggsave("figures/figA_raw_trends_allages.pdf", fig_aa, width = 9, height = 6)
  ggsave("figures/figA_raw_trends_allages.png", fig_aa, width = 9, height = 6, dpi = 300)
  cat("  Saved figures/figA_raw_trends_allages.pdf\n")
}

# ============================================================
# Appendix Figure A2: Event Study — All Ages
# ============================================================

cat("\nCreating Appendix Figure: Event Study (All Ages)\n")

if (file.exists("data/cs_event_study_allages.rds")) {
  cs_event_aa <- readRDS("data/cs_event_study_allages.rds")

  es_aa_df <- data.frame(
    event_time = cs_event_aa$egt,
    att = cs_event_aa$att.egt,
    se = cs_event_aa$se.egt
  ) %>%
    mutate(
      ci_lower = att - 1.96 * se,
      ci_upper = att + 1.96 * se,
      significant = (ci_lower > 0 | ci_upper < 0)
    )

  fig_es_aa <- ggplot(es_aa_df, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey60", linewidth = 0.4) +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50", linewidth = 0.5) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                fill = apep_colors[1], alpha = 0.2) +
    geom_line(color = apep_colors[1], linewidth = 0.8) +
    geom_point(aes(shape = significant), color = apep_colors[1], size = 2.5) +
    scale_shape_manual(values = c("TRUE" = 16, "FALSE" = 1), guide = "none") +
    scale_x_continuous(breaks = seq(-10, 10, 2)) +
    labs(
      title = "Event Study: All-Ages Diabetes Mortality (Appendix)",
      subtitle = "Callaway-Sant'Anna (2021), all ages, age-adjusted",
      x = "Years Relative to Copay Cap Implementation",
      y = "ATT (Deaths per 100,000, All Ages)",
      caption = paste0(
        "Notes: All-ages results shown for comparison with primary working-age analysis.\n",
        "Outcome dilution expected: copay caps affect ~3% of all-ages population."
      )
    ) +
    theme_apep()

  ggsave("figures/figA_event_study_allages.pdf", fig_es_aa, width = 9, height = 6)
  ggsave("figures/figA_event_study_allages.png", fig_es_aa, width = 9, height = 6, dpi = 300)
  cat("  Saved figures/figA_event_study_allages.pdf\n")

} else {
  cat("  All-ages event study not found — skipping appendix figure\n")
}

# ============================================================
# Figure 7: Insulin Utilization Event Study
# ============================================================

cat("\nCreating Figure 7: Insulin Utilization Event Study\n")

if (file.exists("data/es_coefficients_insulin.rds")) {
  es_insulin <- readRDS("data/es_coefficients_insulin.rds")

  fig7 <- ggplot(es_insulin, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey60", linewidth = 0.4) +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50", linewidth = 0.5) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                fill = apep_colors[3], alpha = 0.2) +
    geom_line(color = apep_colors[3], linewidth = 0.8) +
    geom_point(color = apep_colors[3], size = 2.5) +
    annotate("text", x = min(es_insulin$event_time) + 0.5,
             y = max(es_insulin$ci_upper, na.rm = TRUE) * 0.9,
             label = "Pre-treatment", hjust = 0, size = 3.5, color = "grey40") +
    annotate("text", x = 0.5,
             y = max(es_insulin$ci_upper, na.rm = TRUE) * 0.9,
             label = "Post-treatment", hjust = 0, size = 3.5, color = "grey40") +
    scale_x_continuous(breaks = seq(-10, 10, 2)) +
    labs(
      title = "Event Study: Insulin Copay Caps and Medicaid Insulin Prescriptions",
      subtitle = "Callaway-Sant'Anna (2021), outcome = log(Medicaid insulin prescriptions)",
      x = "Years Relative to Copay Cap Implementation",
      y = "ATT (Log Insulin Prescriptions)",
      caption = paste0(
        "Notes: Shaded area = 95% pointwise CI. Reference period: t = -1.\n",
        "Data: CMS Medicaid State Drug Utilization (SDUD), 2015-2024.\n",
        "Medicaid covers a different population than commercial insurance.\n",
        "This tests whether state-level policy attention to insulin access has spillover effects."
      )
    ) +
    theme_apep()

  ggsave("figures/fig7_insulin_event_study.pdf", fig7, width = 9, height = 6)
  ggsave("figures/fig7_insulin_event_study.png", fig7, width = 9, height = 6, dpi = 300)
  cat("  Saved figures/fig7_insulin_event_study.pdf\n")

} else {
  cat("  Insulin event study not found — skipping Figure 7\n")
}

# ============================================================
# Appendix Figure: Suppression Map
# ============================================================

cat("\nCreating Appendix Figure: Suppression Documentation\n")

if (file.exists("data/analysis_panel.rds")) {
  panel_supp <- readRDS("data/analysis_panel.rds")

  # Create suppression summary by state
  supp_summary <- panel_supp %>%
    group_by(state_abbr) %>%
    summarise(
      n_obs = n(),
      n_treated = sum(treated, na.rm = TRUE),
      group = ifelse(any(first_treat > 0), "Ever-Treated", "Never-Treated"),
      .groups = "drop"
    ) %>%
    arrange(group, state_abbr)

  # Simple bar chart of observation counts by state
  fig_supp <- ggplot(supp_summary, aes(x = reorder(state_abbr, n_obs),
                                         y = n_obs, fill = group)) +
    geom_col(alpha = 0.8) +
    coord_flip() +
    scale_fill_manual(values = c("Ever-Treated" = apep_colors[1],
                                  "Never-Treated" = apep_colors[2])) +
    labs(
      title = "Panel Coverage by State",
      subtitle = "Number of state-year observations in working-age (25-64) panel",
      x = NULL, y = "Number of State-Year Observations",
      fill = "Treatment Status",
      caption = paste0(
        "Notes: States with fewer observations have CDC-suppressed cells.\n",
        "Suppression occurs when annual diabetes deaths < 10."
      )
    ) +
    theme_apep() +
    theme(axis.text.y = element_text(size = 7))

  ggsave("figures/figA_suppression.pdf", fig_supp, width = 9, height = 10)
  ggsave("figures/figA_suppression.png", fig_supp, width = 9, height = 10, dpi = 300)
  cat("  Saved figures/figA_suppression.pdf\n")
}

cat("\n=== All Figures Created ===\n")
cat("Figures saved to figures/ directory\n")
