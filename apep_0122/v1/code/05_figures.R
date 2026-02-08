# 05_figures.R — Generate all figures
# Paper 113: RPS and Electricity Sector Employment

source("00_packages.R")

panel <- readRDS("../data/panel.rds")

cat("=== Generating Figures ===\n\n")

# ==============================================================================
# Figure 1: Treatment Rollout Map
# ==============================================================================

cat("Figure 1: Treatment rollout...\n")

rps_policy <- readRDS("../data/rps_policy.rds")

rollout_df <- rps_policy %>%
  mutate(
    adoption_period = case_when(
      is.na(rps_first_binding) ~ "No RPS",
      rps_first_binding <= 2003 ~ "1999-2003",
      rps_first_binding <= 2007 ~ "2004-2007",
      rps_first_binding <= 2012 ~ "2008-2012",
      rps_first_binding >= 2013 ~ "2013+",
      TRUE ~ "No RPS"
    ),
    adoption_period = factor(adoption_period,
                              levels = c("1999-2003", "2004-2007", "2008-2012",
                                          "2013+", "No RPS"))
  )

# Cohort size bar chart
cohort_sizes <- rollout_df %>%
  count(adoption_period) %>%
  filter(!is.na(adoption_period))

p1 <- ggplot(cohort_sizes, aes(x = adoption_period, y = n, fill = adoption_period)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = n), vjust = -0.5, size = 3.5) +
  scale_fill_manual(values = c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", "gray70")) +
  labs(
    title = "RPS Adoption Cohorts",
    subtitle = "Number of states by first binding compliance year",
    x = "Adoption Period",
    y = "Number of States"
  ) +
  theme(legend.position = "none") +
  ylim(0, max(cohort_sizes$n) + 3)

ggsave("../figures/fig1_treatment_rollout.pdf", p1, width = 8, height = 5)
cat("  Saved: fig1_treatment_rollout.pdf\n")

# ==============================================================================
# Figure 2: Average Outcomes by Treatment Status (Pre-Trends Visual)
# ==============================================================================

cat("Figure 2: Outcome trends by group...\n")

trends <- panel %>%
  group_by(year, ever_treated) %>%
  summarise(
    mean_rate = mean(elec_emp_rate, na.rm = TRUE),
    se_rate = sd(elec_emp_rate, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(group = ifelse(ever_treated, "RPS States", "Non-RPS States"))

p2 <- ggplot(trends, aes(x = year, y = mean_rate, color = group, shape = group)) +
  geom_point(size = 2) +
  geom_line(linewidth = 0.7) +
  geom_ribbon(aes(ymin = mean_rate - 1.96 * se_rate,
                  ymax = mean_rate + 1.96 * se_rate, fill = group),
              alpha = 0.15, color = NA) +
  scale_color_manual(values = c("RPS States" = "#1b9e77", "Non-RPS States" = "#d95f02")) +
  scale_fill_manual(values = c("RPS States" = "#1b9e77", "Non-RPS States" = "#d95f02")) +
  labs(
    title = "Electricity Sector Employment Rate by RPS Status",
    subtitle = "Employees per 1,000 population, ACS 1-Year PUMS",
    x = "Year",
    y = "Employment Rate (per 1,000)",
    color = NULL, fill = NULL, shape = NULL
  ) +
  theme(legend.position = "bottom")

ggsave("../figures/fig2_outcome_trends.pdf", p2, width = 9, height = 6)
cat("  Saved: fig2_outcome_trends.pdf\n")

# ==============================================================================
# Figure 3: Event Study — Callaway-Sant'Anna (Primary)
# ==============================================================================

cat("Figure 3: CS-DiD event study...\n")

es_df <- readRDS("../data/event_study_cs.rds")

p3 <- ggplot(es_df, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "red", alpha = 0.5) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), fill = "#1b9e77", alpha = 0.2) +
  geom_point(size = 2.5, color = "#1b9e77") +
  geom_line(color = "#1b9e77", linewidth = 0.5) +
  labs(
    title = "Event Study: RPS and Electricity Sector Employment",
    subtitle = "Callaway-Sant'Anna ATT estimates, not-yet-treated comparison",
    x = "Years Relative to First Binding RPS Compliance",
    y = "ATT (Employment Rate per 1,000)",
    caption = "Notes: Shaded area shows 95% pointwise confidence intervals.\nEstimated using doubly-robust Callaway-Sant'Anna (2021) estimator."
  ) +
  scale_x_continuous(breaks = seq(-8, 10, 2)) +
  annotate("text", x = -4, y = max(es_df$ci_upper, na.rm = TRUE) * 0.9,
           label = "Pre-treatment", fontface = "italic", color = "gray40", size = 3.5) +
  annotate("text", x = 5, y = max(es_df$ci_upper, na.rm = TRUE) * 0.9,
           label = "Post-treatment", fontface = "italic", color = "gray40", size = 3.5)

ggsave("../figures/fig3_event_study_cs.pdf", p3, width = 9, height = 6)
cat("  Saved: fig3_event_study_cs.pdf\n")

# ==============================================================================
# Figure 4: Event Study Comparison (CS vs SA vs TWFE)
# ==============================================================================

cat("Figure 4: Estimator comparison...\n")

# Sun-Abraham event study
sa_result <- readRDS("../data/sa_result.rds")
sa_coefs <- as.data.frame(coeftable(sa_result))
sa_coefs$event_time <- as.numeric(gsub(".*::", "", rownames(sa_coefs)))
sa_coefs$estimator <- "Sun-Abraham"
names(sa_coefs)[1:2] <- c("estimate", "se")
sa_coefs$ci_lower <- sa_coefs$estimate - 1.96 * sa_coefs$se
sa_coefs$ci_upper <- sa_coefs$estimate + 1.96 * sa_coefs$se

# CS event study
cs_es <- es_df %>% mutate(estimator = "Callaway-Sant'Anna")

# Combine
compare_df <- bind_rows(
  cs_es %>% select(event_time, estimate, ci_lower, ci_upper, estimator),
  sa_coefs %>% select(event_time, estimate, ci_lower, ci_upper, estimator)
) %>%
  filter(event_time >= -8, event_time <= 10)

p4 <- ggplot(compare_df, aes(x = event_time, y = estimate,
                              color = estimator, shape = estimator)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "red", alpha = 0.5) +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper),
                  position = position_dodge(width = 0.5), size = 0.3) +
  scale_color_manual(values = c("Callaway-Sant'Anna" = "#1b9e77", "Sun-Abraham" = "#d95f02")) +
  labs(
    title = "Event Study: Comparing Heterogeneity-Robust Estimators",
    subtitle = "Effect of RPS on electricity sector employment rate",
    x = "Years Relative to First Binding RPS Compliance",
    y = "Estimated ATT (Employment Rate per 1,000)",
    color = "Estimator", shape = "Estimator",
    caption = "Notes: Both estimators account for heterogeneous treatment effects.\n95% confidence intervals shown."
  ) +
  scale_x_continuous(breaks = seq(-8, 10, 2)) +
  theme(legend.position = "bottom")

ggsave("../figures/fig4_estimator_comparison.pdf", p4, width = 9, height = 6)
cat("  Saved: fig4_estimator_comparison.pdf\n")

# ==============================================================================
# Figure 5: Placebo Tests
# ==============================================================================

cat("Figure 5: Placebo tests...\n")

tryCatch({
  cs_event_mfg <- readRDS("../data/cs_event_placebo_mfg.rds")

  placebo_df <- data.frame(
    event_time = cs_event_mfg$egt,
    estimate = cs_event_mfg$att.egt,
    se = cs_event_mfg$se.egt,
    ci_lower = cs_event_mfg$att.egt - 1.96 * cs_event_mfg$se.egt,
    ci_upper = cs_event_mfg$att.egt + 1.96 * cs_event_mfg$se.egt,
    outcome = "Manufacturing (Placebo)"
  )

  # Add main result for comparison
  main_es <- es_df %>%
    mutate(outcome = "Electricity Sector (Main)")

  placebo_compare <- bind_rows(
    main_es %>% select(event_time, estimate, ci_lower, ci_upper, outcome),
    placebo_df %>% select(event_time, estimate, ci_lower, ci_upper, outcome)
  ) %>%
    filter(event_time >= -8, event_time <= 10)

  p5 <- ggplot(placebo_compare, aes(x = event_time, y = estimate,
                                    color = outcome, shape = outcome)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "red", alpha = 0.5) +
    geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper),
                    position = position_dodge(width = 0.5), size = 0.3) +
    scale_color_manual(values = c("Electricity Sector (Main)" = "#1b9e77",
                                   "Manufacturing (Placebo)" = "#d95f02")) +
    labs(
      title = "Main Effect vs. Placebo Test",
      subtitle = "Manufacturing employment should be unaffected by RPS",
      x = "Years Relative to First Binding RPS Compliance",
      y = "Estimated ATT (Employment Rate per 1,000)",
      color = "Outcome", shape = "Outcome",
      caption = "Notes: Manufacturing employment serves as a placebo outcome.\nRPS directly targets the electricity sector, not manufacturing."
    ) +
    scale_x_continuous(breaks = seq(-8, 10, 2)) +
    theme(legend.position = "bottom")

  ggsave("../figures/fig5_placebo_tests.pdf", p5, width = 9, height = 6)
  cat("  Saved: fig5_placebo_tests.pdf\n")
}, error = function(e) {
  cat(sprintf("  Placebo figure error: %s\n", e$message))
})

# ==============================================================================
# Figure 6: Leave-One-Out Sensitivity
# ==============================================================================

cat("Figure 6: Leave-one-out...\n")

tryCatch({
  loo_results <- readRDS("../data/loo_results.rds")
  main_results <- readRDS("../data/main_results.rds")
  main_att <- main_results$att[1]

  p6 <- ggplot(loo_results, aes(x = reorder(state_name, att), y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_hline(yintercept = main_att, linetype = "solid", color = "#1b9e77", alpha = 0.5) +
    geom_point(size = 2, color = "#7570b3") +
    geom_errorbar(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                  width = 0.3, color = "#7570b3", alpha = 0.6) +
    coord_flip() +
    labs(
      title = "Leave-One-Out Sensitivity Analysis",
      subtitle = "ATT after excluding each treated state",
      x = "Excluded State",
      y = "Estimated ATT (Employment Rate per 1,000)",
      caption = "Notes: Green line shows full-sample ATT estimate.\nDashed line shows zero effect."
    )

  ggsave("../figures/fig6_leave_one_out.pdf", p6, width = 8, height = 10)
  cat("  Saved: fig6_leave_one_out.pdf\n")
}, error = function(e) {
  cat(sprintf("  LOO figure error: %s\n", e$message))
})

cat("\n=== All figures generated ===\n")
