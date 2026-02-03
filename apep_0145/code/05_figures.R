###############################################################################
# 05_figures.R
# Paper 145: EERS and Residential Electricity Consumption (Revision of apep_0144)
# Generate all publication-quality figures
#
# REVISION NOTES (apep_0145):
#   - ADDED: Figure 8 - HonestDiD M-sensitivity curve
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
fig_dir  <- "../figures/"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel <- readRDS(paste0(data_dir, "panel_clean.rds"))

###############################################################################
# Figure 1: Treatment Rollout (already in 03, but refined version here)
###############################################################################

rollout <- panel %>%
  filter(eers_year > 0) %>%
  distinct(state_abbr, eers_year) %>%
  arrange(eers_year)

fig1 <- ggplot(rollout, aes(x = eers_year, y = reorder(state_abbr, -eers_year))) +
  geom_point(size = 2.5, color = apep_colors["treated"]) +
  geom_segment(aes(x = eers_year, xend = 2023,
                   y = reorder(state_abbr, -eers_year),
                   yend = reorder(state_abbr, -eers_year)),
               color = apep_colors["treated"], alpha = 0.25, linewidth = 0.4) +
  labs(
    title = "Staggered Adoption of Energy Efficiency Resource Standards",
    subtitle = "Mandatory EERS with binding savings targets; lines indicate treatment duration",
    x = "Year of EERS Adoption",
    y = ""
  ) +
  scale_x_continuous(breaks = seq(1998, 2022, 4), limits = c(1997, 2024)) +
  theme(
    axis.text.y = element_text(size = 7),
    panel.grid.major.y = element_line(color = "gray95")
  )

ggsave(paste0(fig_dir, "fig1_treatment_rollout.pdf"), fig1,
       width = 7, height = 9, units = "in")

###############################################################################
# Figure 2: Raw Trends by Treatment Group
###############################################################################

group_means <- panel %>%
  filter(!is.na(res_elec_pc)) %>%
  mutate(group = ifelse(treated == 1, "EERS States", "Non-EERS States")) %>%
  group_by(year, group) %>%
  summarise(
    mean_val = mean(res_elec_pc, na.rm = TRUE),
    se = sd(res_elec_pc, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

fig2 <- ggplot(group_means, aes(x = year, y = mean_val, color = group)) +
  geom_line(linewidth = 0.9) +
  geom_ribbon(aes(ymin = mean_val - 1.96 * se, ymax = mean_val + 1.96 * se,
                  fill = group), alpha = 0.12, color = NA) +
  scale_color_manual(values = c("EERS States" = apep_colors["treated"],
                                "Non-EERS States" = apep_colors["control"])) +
  scale_fill_manual(values = c("EERS States" = apep_colors["treated"],
                               "Non-EERS States" = apep_colors["control"])) +
  labs(
    title = "Mean Per-Capita Residential Electricity Consumption by EERS Status",
    subtitle = "Shaded bands show 95% confidence intervals around group means",
    x = "Year",
    y = "Per-Capita Residential Electricity (Billion Btu)",
    color = "", fill = ""
  ) +
  scale_x_continuous(breaks = seq(1994, 2023, 4), limits = c(1993, 2024))

ggsave(paste0(fig_dir, "fig2_raw_trends.pdf"), fig2,
       width = 9, height = 6, units = "in")

###############################################################################
# Figure 3: Event Study — Main Specification
###############################################################################

cs_dynamic <- readRDS(paste0(data_dir, "cs_att_dynamic.rds"))
cs_att <- readRDS(paste0(data_dir, "cs_att_simple.rds"))

es_data <- data.frame(
  event_time = cs_dynamic$egt,
  estimate = cs_dynamic$att.egt,
  se = cs_dynamic$se.egt
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    pre_post = ifelse(event_time < 0, "Pre-treatment", "Post-treatment")
  )

fig3 <- ggplot(es_data, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50", linewidth = 0.4) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70", linewidth = 0.4) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15,
              fill = apep_colors["treated"]) +
  geom_line(color = apep_colors["treated"], linewidth = 0.6) +
  geom_point(aes(color = pre_post), size = 2.2) +
  scale_color_manual(values = c("Pre-treatment" = "gray50",
                                "Post-treatment" = apep_colors["treated"])) +
  labs(
    title = "Dynamic Treatment Effects of EERS on Residential Electricity",
    subtitle = paste0("Callaway-Sant'Anna estimator | Never-treated control | ",
                      "Overall ATT = ", round(cs_att$overall.att, 4),
                      " (SE = ", round(cs_att$overall.se, 4), ")"),
    x = "Years Since EERS Adoption",
    y = "ATT (Log Points)",
    color = ""
  ) +
  scale_x_continuous(breaks = seq(-10, 15, 2)) +
  theme(legend.position = c(0.85, 0.15))

ggsave(paste0(fig_dir, "fig3_event_study_main.pdf"), fig3,
       width = 10, height = 6, units = "in")

###############################################################################
# Figure 4: Event Study Comparison — Never-Treated vs. Not-Yet-Treated
###############################################################################

cs_nyt_dynamic <- tryCatch(readRDS(paste0(data_dir, "cs_nyt_dynamic.rds")),
                           error = function(e) NULL)

if (!is.null(cs_nyt_dynamic)) {
  es_nt <- data.frame(
    event_time = cs_dynamic$egt,
    estimate = cs_dynamic$att.egt,
    se = cs_dynamic$se.egt,
    control = "Never-treated"
  )

  es_nyt <- data.frame(
    event_time = cs_nyt_dynamic$egt,
    estimate = cs_nyt_dynamic$att.egt,
    se = cs_nyt_dynamic$se.egt,
    control = "Not-yet-treated"
  )

  es_both <- bind_rows(es_nt, es_nyt) %>%
    filter(!is.na(control), !is.na(estimate)) %>%
    mutate(
      ci_lower = estimate - 1.96 * se,
      ci_upper = estimate + 1.96 * se
    )

  fig4 <- ggplot(es_both, aes(x = event_time, y = estimate, color = control,
                              fill = control)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.1, color = NA) +
    geom_line(linewidth = 0.6) +
    geom_point(size = 1.8) +
    scale_color_manual(values = c("Never-treated" = apep_colors["treated"],
                                  "Not-yet-treated" = apep_colors["control"])) +
    scale_fill_manual(values = c("Never-treated" = apep_colors["treated"],
                                 "Not-yet-treated" = apep_colors["control"])) +
    labs(
      title = "Robustness: Alternative Control Groups",
      subtitle = "CS event study with never-treated vs. not-yet-treated comparison groups",
      x = "Years Since EERS Adoption",
      y = "ATT (Log Points)",
      color = "Control Group", fill = "Control Group"
    ) +
    scale_x_continuous(breaks = seq(-10, 15, 2))

  ggsave(paste0(fig_dir, "fig4_control_group_comparison.pdf"), fig4,
         width = 10, height = 6, units = "in")
}

###############################################################################
# Figure 5: Group-Level ATT (by adoption cohort)
###############################################################################

cs_group <- readRDS(paste0(data_dir, "cs_att_group.rds"))

group_data <- data.frame(
  cohort = cs_group$egt,
  att = cs_group$att.egt,
  se = cs_group$se.egt
) %>%
  filter(!is.na(att), !is.na(se)) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    sig = ifelse(ci_lower > 0 | ci_upper < 0, "Significant", "Not Significant")
  )

fig5 <- ggplot(group_data, aes(x = factor(cohort), y = att, color = sig)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper), size = 0.5) +
  scale_color_manual(values = c("Significant" = apep_colors["treated"],
                                "Not Significant" = "gray50")) +
  labs(
    title = "Group-Level Average Treatment Effects by Adoption Cohort",
    subtitle = "CS estimator, 95% CIs; each cohort is a set of states adopting in the same year",
    x = "EERS Adoption Year (Cohort)",
    y = "ATT (Log Points)",
    color = ""
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(paste0(fig_dir, "fig5_group_att.pdf"), fig5,
       width = 9, height = 6, units = "in")

###############################################################################
# Figure 6: Alternative Outcomes Event Studies
###############################################################################

cs_total_dynamic <- tryCatch(readRDS(paste0(data_dir, "cs_total_dynamic.rds")),
                             error = function(e) NULL)
cs_price_dynamic <- tryCatch(readRDS(paste0(data_dir, "cs_price_dynamic.rds")),
                             error = function(e) NULL)

outcomes_list <- list()

# Main: residential
outcomes_list[["Residential Electricity"]] <- data.frame(
  event_time = cs_dynamic$egt,
  estimate = cs_dynamic$att.egt,
  se = cs_dynamic$se.egt
)

if (!is.null(cs_total_dynamic)) {
  outcomes_list[["Total Electricity"]] <- data.frame(
    event_time = cs_total_dynamic$egt,
    estimate = cs_total_dynamic$att.egt,
    se = cs_total_dynamic$se.egt
  )
}

if (!is.null(cs_price_dynamic)) {
  outcomes_list[["Residential Prices"]] <- data.frame(
    event_time = cs_price_dynamic$egt,
    estimate = cs_price_dynamic$att.egt,
    se = cs_price_dynamic$se.egt
  )
}

if (length(outcomes_list) > 1) {
  es_outcomes <- bind_rows(outcomes_list, .id = "outcome") %>%
    mutate(
      ci_lower = estimate - 1.96 * se,
      ci_upper = estimate + 1.96 * se
    )

  fig6 <- ggplot(es_outcomes, aes(x = event_time, y = estimate, color = outcome,
                                   fill = outcome)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.08, color = NA) +
    geom_line(linewidth = 0.5) +
    geom_point(size = 1.5) +
    facet_wrap(~outcome, scales = "free_y", ncol = 1) +
    labs(
      title = "EERS Effects Across Outcome Variables",
      subtitle = "CS estimator, never-treated control, 95% CIs",
      x = "Years Since EERS Adoption",
      y = "ATT (Log Points)"
    ) +
    scale_x_continuous(breaks = seq(-10, 15, 5)) +
    theme(legend.position = "none")

  ggsave(paste0(fig_dir, "fig6_alternative_outcomes.pdf"), fig6,
         width = 9, height = 10, units = "in")
}

###############################################################################
# Figure 7: Summary of ATT Estimates Across Specifications
###############################################################################

rob_summary <- tryCatch(readRDS(paste0(data_dir, "robustness_summary.rds")),
                        error = function(e) NULL)

if (!is.null(rob_summary)) {
  rob_plot_data <- rob_summary %>%
    filter(!is.na(ATT), !is.na(SE)) %>%
    mutate(
      ci_lower = ATT - 1.96 * SE,
      ci_upper = ATT + 1.96 * SE,
      spec_type = case_when(
        grepl("Main", Specification) ~ "Main",
        grepl("Placebo", Specification) ~ "Placebo",
        TRUE ~ "Robustness"
      )
    )

  fig7 <- ggplot(rob_plot_data, aes(x = ATT, y = reorder(Specification, ATT),
                                     color = spec_type)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
    geom_pointrange(aes(xmin = ci_lower, xmax = ci_upper), size = 0.7, linewidth = 0.8) +
    scale_color_manual(values = c("Main" = "#1B3A5C",
                                  "Robustness" = "#E67E22",
                                  "Placebo" = "#AAAAAA")) +
    labs(
      title = "Summary of ATT Estimates Across Specifications",
      subtitle = "Point estimates with 95% CIs; main specification in dark blue, robustness in orange, placebos in gray",
      x = "ATT (Log Points)",
      y = "",
      color = "Type"
    )

  ggsave(paste0(fig_dir, "fig7_robustness_forest.pdf"), fig7,
         width = 9, height = 5, units = "in")
}

###############################################################################
# Figure 8: HonestDiD M-Sensitivity Curve (NEW in apep_0145)
#
# Shows how confidence intervals for the treatment effect change as we relax
# the parallel trends assumption. M parameter bounds the change in slope of
# differential trends between consecutive periods.
###############################################################################

sensitivity_curve <- tryCatch(readRDS(paste0(data_dir, "honest_sensitivity_curve.rds")),
                              error = function(e) NULL)

if (!is.null(sensitivity_curve)) {
  # Reshape for plotting - two panels: Overall ATT and Event Time 15
  curve_overall <- sensitivity_curve %>%
    select(M, estimate = overall_estimate, lb = overall_lb, ub = overall_ub) %>%
    mutate(outcome = "Overall ATT (~8 years avg)")

  curve_e15 <- sensitivity_curve %>%
    select(M, estimate = e15_estimate, lb = e15_lb, ub = e15_ub) %>%
    mutate(outcome = "Event Time 15 (long-run)")

  curve_combined <- bind_rows(curve_overall, curve_e15) %>%
    filter(!is.na(estimate))

  # Find M value where CI crosses zero
  m_cross_overall <- curve_overall %>%
    filter(ub >= 0) %>%
    slice(1) %>%
    pull(M)

  m_cross_e15 <- curve_e15 %>%
    filter(ub >= 0) %>%
    slice(1) %>%
    pull(M)

  fig8 <- ggplot(curve_combined, aes(x = M)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50", linewidth = 0.4) +
    geom_ribbon(aes(ymin = lb, ymax = ub, fill = outcome), alpha = 0.2) +
    geom_line(aes(y = estimate, color = outcome), linewidth = 1) +
    geom_line(aes(y = lb, color = outcome), linewidth = 0.4, linetype = "dashed") +
    geom_line(aes(y = ub, color = outcome), linewidth = 0.4, linetype = "dashed") +
    facet_wrap(~outcome, scales = "free_y", ncol = 1) +
    scale_color_manual(values = c("Overall ATT (~8 years avg)" = apep_colors["treated"],
                                  "Event Time 15 (long-run)" = apep_colors["control"])) +
    scale_fill_manual(values = c("Overall ATT (~8 years avg)" = apep_colors["treated"],
                                 "Event Time 15 (long-run)" = apep_colors["control"])) +
    labs(
      title = "Sensitivity to Parallel Trends Violations (Honest DiD)",
      subtitle = "Confidence intervals under smoothness restrictions; M bounds change in slope of differential trends",
      x = expression(paste("M (Maximum Change in Trend Slope, ", Delta, ")")),
      y = "ATT (Log Points)",
      caption = paste0("M=0: exact parallel trends. ",
                       "Overall ATT crosses zero at M=", ifelse(length(m_cross_overall) > 0, round(m_cross_overall, 3), ">0.08"), ". ",
                       "Event time 15 crosses zero at M=", ifelse(length(m_cross_e15) > 0, round(m_cross_e15, 3), ">0.08"), ".")
    ) +
    theme(legend.position = "none") +
    scale_x_continuous(breaks = seq(0, 0.08, 0.02))

  ggsave(paste0(fig_dir, "fig8_honest_sensitivity.pdf"), fig8,
         width = 9, height = 8, units = "in")

  cat("Figure 8 (HonestDiD sensitivity) saved.\n")
}

###############################################################################
# Figure 9: Honest Intervals by Event Time (5, 10, 15)
###############################################################################

honest_by_event <- tryCatch(readRDS(paste0(data_dir, "honest_by_event_time.rds")),
                            error = function(e) NULL)

if (!is.null(honest_by_event)) {
  # Reshape for plotting
  honest_long <- honest_by_event %>%
    pivot_longer(
      cols = starts_with("ci_"),
      names_to = c(".value", "M_level"),
      names_pattern = "ci_(lower|upper)_m(.*)"
    ) %>%
    mutate(
      M_label = case_when(
        M_level == "0" ~ "M = 0 (Exact PT)",
        M_level == "02" ~ "M = 0.02 (Modest)",
        M_level == "05" ~ "M = 0.05 (Large)"
      ),
      M_label = factor(M_label, levels = c("M = 0 (Exact PT)", "M = 0.02 (Modest)", "M = 0.05 (Large)"))
    )

  fig9 <- ggplot(honest_long, aes(x = factor(event_time), y = estimate, color = M_label)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_pointrange(aes(ymin = lower, ymax = upper),
                    position = position_dodge(width = 0.5), size = 0.6) +
    scale_color_manual(values = c("M = 0 (Exact PT)" = apep_colors["treated"],
                                  "M = 0.02 (Modest)" = "#E67E22",
                                  "M = 0.05 (Large)" = apep_colors["control"])) +
    labs(
      title = "Honest Confidence Intervals at Key Event Times",
      subtitle = "Effect estimates with intervals under varying parallel trends assumptions",
      x = "Event Time (Years Since EERS Adoption)",
      y = "ATT (Log Points)",
      color = "Assumption"
    ) +
    theme(legend.position = "bottom")

  ggsave(paste0(fig_dir, "fig9_honest_by_event.pdf"), fig9,
         width = 8, height = 6, units = "in")

  cat("Figure 9 (Honest intervals by event time) saved.\n")
}

cat("\nAll figures saved to:", fig_dir, "\n")
