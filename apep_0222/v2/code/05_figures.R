##############################################################################
# 05_figures.R — Publication-quality figures
# APEP-0222 v2: Educational Content Restriction Laws and Teacher Labor Markets
# Revision: adds Fig 7 (female share ES) and Fig 8 (6111 vs 61 comparison)
##############################################################################

source("00_packages.R")

cat("=== Generating figures ===\n")

# Load data and results
edu_panel <- readRDS("../data/edu_panel.rds")
panel <- readRDS("../data/panel.rds")
results <- readRDS("../data/main_results.rds")
treatment_laws <- readRDS("../data/treatment_laws.rds")
robust_results <- readRDS("../data/robust_results.rds")

# Helper function
extract_es_data <- function(es_obj, outcome_label) {
  tibble(
    event_time = es_obj$egt,
    estimate = es_obj$att.egt,
    se = es_obj$se.egt,
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    outcome = outcome_label
  )
}

# ============================================================================
# FIGURE 1: Treatment Rollout
# ============================================================================

cat("Figure 1: Treatment rollout...\n")

rollout_data <- treatment_laws %>% arrange(effective_date)

fig1 <- ggplot(rollout_data,
               aes(x = effective_date,
                   y = reorder(state_name, effective_date),
                   color = stringency)) +
  geom_point(size = 3) +
  geom_segment(aes(xend = as.Date("2024-12-31"), yend = state_name), alpha = 0.3) +
  scale_color_manual(values = c("strong" = "#D55E00", "moderate" = "#0072B2", "weak" = "#009E73"),
                     labels = c("Strong (penalties/sanctions)", "Moderate (prohibitions)", "Weak (advisory/proviso)"),
                     name = "Law Stringency") +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y",
               limits = c(as.Date("2021-01-01"), as.Date("2024-12-31"))) +
  labs(title = "Staggered Adoption of Educational Content Restriction Laws",
       subtitle = "Effective dates by state and law stringency, 2021-2024",
       x = "Effective Date", y = NULL,
       caption = "Sources: PEN America, Heritage Foundation, state legislative records") +
  theme_apep() +
  theme(legend.position = "bottom", axis.text.y = element_text(size = 8))

ggsave("../figures/fig1_treatment_rollout.pdf", fig1, width = 8, height = 10)
ggsave("../figures/fig1_treatment_rollout.png", fig1, width = 8, height = 10, dpi = 300)

# ============================================================================
# FIGURE 2: Raw Trends — K-12 Employment by Treatment Status
# ============================================================================

cat("Figure 2: Raw trends...\n")

raw_trends <- edu_panel %>%
  filter(!is.na(Emp)) %>%
  mutate(group = ifelse(treated_state, "Treated States", "Never-Treated States")) %>%
  group_by(group, year, quarter) %>%
  summarise(
    mean_emp = mean(Emp, na.rm = TRUE),
    mean_earn = mean(EarnS, na.rm = TRUE),
    mean_sep_rate = mean(Sep / (Emp + 1), na.rm = TRUE),
    mean_hire_rate = mean(HirA / (Emp + 1), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(time_q = year + (quarter - 1) / 4)

baseline <- raw_trends %>%
  filter(year == 2020, quarter == 4) %>%
  select(group, baseline_emp = mean_emp, baseline_earn = mean_earn)

raw_trends <- raw_trends %>%
  left_join(baseline, by = "group") %>%
  mutate(
    emp_index = 100 * mean_emp / baseline_emp,
    earn_index = 100 * mean_earn / baseline_earn
  )

p2a <- ggplot(raw_trends, aes(x = time_q, y = emp_index, color = group)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = 2021.5, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2021.7, y = max(raw_trends$emp_index, na.rm = TRUE),
           label = "First laws\ntake effect", size = 3, hjust = 0, color = "grey40") +
  scale_color_manual(values = apep_colors[1:2], name = NULL) +
  labs(title = "A. K-12 School Employment (NAICS 6111)",
       subtitle = "Average state employment, indexed to 2020Q4 = 100",
       x = "Year-Quarter", y = "Employment Index (2020Q4 = 100)") +
  theme_apep()

p2b <- ggplot(raw_trends, aes(x = time_q, y = mean_sep_rate, color = group)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = 2021.5, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = apep_colors[1:2], name = NULL) +
  labs(title = "B. K-12 School Separation Rate (NAICS 6111)",
       subtitle = "Average quarterly separations / employment",
       x = "Year-Quarter", y = "Separation Rate") +
  theme_apep()

fig2 <- p2a / p2b + plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

ggsave("../figures/fig2_raw_trends.pdf", fig2, width = 8, height = 10)
ggsave("../figures/fig2_raw_trends.png", fig2, width = 8, height = 10, dpi = 300)

# ============================================================================
# FIGURE 3: Event Study — Callaway-Sant'Anna (NAICS 6111)
# ============================================================================

cat("Figure 3: Event studies...\n")

es_emp_df <- extract_es_data(results$es_emp, "Log Employment")

p3a <- ggplot(es_emp_df, aes(x = event_time, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_point(color = apep_colors[1], size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
  labs(title = "A. Log Employment",
       subtitle = "CS event study, NAICS 6111 (K-12 Schools)",
       x = "Quarters Relative to Law Effective Date", y = "ATT") +
  theme_apep()

es_sep_df <- extract_es_data(results$es_sep, "Separation Rate")
p3b <- ggplot(es_sep_df, aes(x = event_time, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = apep_colors[2]) +
  geom_line(color = apep_colors[2], linewidth = 0.8) +
  geom_point(color = apep_colors[2], size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
  labs(title = "B. Separation Rate", x = "Quarters Relative to Law Effective Date", y = "ATT") +
  theme_apep()

es_earn_df <- extract_es_data(results$es_earn, "Log Earnings")
p3c <- ggplot(es_earn_df, aes(x = event_time, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = apep_colors[3]) +
  geom_line(color = apep_colors[3], linewidth = 0.8) +
  geom_point(color = apep_colors[3], size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
  labs(title = "C. Log Earnings", x = "Quarters Relative to Law Effective Date", y = "ATT") +
  theme_apep()

es_hire_df <- extract_es_data(results$es_hire, "Hire Rate")
p3d <- ggplot(es_hire_df, aes(x = event_time, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = apep_colors[4]) +
  geom_line(color = apep_colors[4], linewidth = 0.8) +
  geom_point(color = apep_colors[4], size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
  labs(title = "D. Hire Rate", x = "Quarters Relative to Law Effective Date", y = "ATT") +
  theme_apep()

fig3 <- (p3a | p3b) / (p3c | p3d)
ggsave("../figures/fig3_event_study.pdf", fig3, width = 12, height = 10)
ggsave("../figures/fig3_event_study.png", fig3, width = 12, height = 10, dpi = 300)

# ============================================================================
# FIGURE 4: Placebo Event Studies
# ============================================================================

cat("Figure 4: Placebo event studies...\n")

if (!is.null(robust_results$placebo_results)) {
  placebo_es_data <- list()
  for (ind in names(robust_results$placebo_results)) {
    pr <- robust_results$placebo_results[[ind]]
    placebo_es_data[[ind]] <- extract_es_data(pr$es, pr$industry)
  }

  placebo_es_all <- bind_rows(
    extract_es_data(results$es_emp, "K-12 Schools (Treated)"),
    bind_rows(placebo_es_data)
  )

  fig4 <- ggplot(placebo_es_all, aes(x = event_time, y = estimate, color = outcome, fill = outcome)) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.1) +
    geom_line(linewidth = 0.7) +
    geom_point(size = 1.5) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
    scale_color_manual(values = c(apep_colors[1:4]), name = "Sector") +
    scale_fill_manual(values = c(apep_colors[1:4]), name = "Sector") +
    labs(title = "Event Study by Sector: K-12 Schools vs. Placebo Industries",
         subtitle = "Callaway-Sant'Anna estimates, log employment, NAICS 6111 vs. placebo sectors",
         x = "Quarters Relative to Law Effective Date",
         y = "ATT (Log Employment)",
         caption = "Laws coded at effective date. Placebo sectors should show null effects.") +
    theme_apep() + theme(legend.position = "bottom")

  ggsave("../figures/fig4_placebo_event_study.pdf", fig4, width = 10, height = 7)
  ggsave("../figures/fig4_placebo_event_study.png", fig4, width = 10, height = 7, dpi = 300)
}

# ============================================================================
# FIGURE 5: Heterogeneity by Stringency
# ============================================================================

cat("Figure 5: Heterogeneity by stringency...\n")

if (!is.null(robust_results$es_strong) && !is.null(robust_results$es_mw)) {
  het_data <- bind_rows(
    extract_es_data(robust_results$es_strong, "Strong Laws"),
    extract_es_data(robust_results$es_mw, "Moderate/Weak Laws")
  )

  fig5 <- ggplot(het_data, aes(x = event_time, y = estimate, color = outcome, fill = outcome)) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15) +
    geom_line(linewidth = 0.8) + geom_point(size = 2) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
    scale_color_manual(values = c("#D55E00", "#0072B2"), name = NULL) +
    scale_fill_manual(values = c("#D55E00", "#0072B2"), name = NULL) +
    labs(title = "Event Study by Law Stringency (NAICS 6111)",
         subtitle = "Strong laws (penalties) vs. moderate/weak (prohibitions/advisory)",
         x = "Quarters Relative to Law Effective Date", y = "ATT (Log Employment)") +
    theme_apep()

  ggsave("../figures/fig5_heterogeneity_stringency.pdf", fig5, width = 10, height = 7)
  ggsave("../figures/fig5_heterogeneity_stringency.png", fig5, width = 10, height = 7, dpi = 300)
}

# ============================================================================
# FIGURE 6: Randomization Inference
# ============================================================================

cat("Figure 6: Randomization inference...\n")

if (!is.null(robust_results$perm_coefs)) {
  ri_data <- tibble(coef = robust_results$perm_coefs)
  obs <- robust_results$obs_coef

  fig6 <- ggplot(ri_data, aes(x = coef)) +
    geom_histogram(bins = 50, fill = "grey70", color = "white") +
    geom_vline(xintercept = obs, color = "#D55E00", linewidth = 1.2) +
    annotate("text", x = obs, y = Inf, label = sprintf("Observed = %.4f", obs),
             vjust = -0.5, hjust = -0.1, color = "#D55E00", fontface = "bold", size = 3.5) +
    labs(title = "Randomization Inference: Permutation Distribution",
         subtitle = sprintf("1,000 permutations | Fisher p = %.3f", robust_results$fisher_p),
         x = "TWFE Coefficient (Log Employment, NAICS 6111)", y = "Count") +
    theme_apep()

  ggsave("../figures/fig6_randomization_inference.pdf", fig6, width = 8, height = 6)
  ggsave("../figures/fig6_randomization_inference.png", fig6, width = 8, height = 6, dpi = 300)
}

# ============================================================================
# FIGURE 7: Female Share CS Event Study (NEW)
# ============================================================================

cat("Figure 7: Female share event study...\n")

if (!is.null(results$es_female)) {
  es_female_df <- extract_es_data(results$es_female, "Female Share")

  fig7 <- ggplot(es_female_df, aes(x = event_time, y = estimate)) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = apep_colors[4]) +
    geom_line(color = apep_colors[4], linewidth = 0.8) +
    geom_point(color = apep_colors[4], size = 2) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
    labs(title = "Female Share of K-12 Education Workforce",
         subtitle = "Callaway-Sant'Anna event study, NAICS 6111 (K-12 Schools)",
         x = "Quarters Relative to Law Effective Date",
         y = "ATT (Female Share, pp)",
         caption = "Sex-disaggregated QWI data for NAICS 6111. Positive = higher female share post-treatment.") +
    theme_apep()

  ggsave("../figures/fig7_female_share_event_study.pdf", fig7, width = 8, height = 6)
  ggsave("../figures/fig7_female_share_event_study.png", fig7, width = 8, height = 6, dpi = 300)
} else {
  cat("  Skipped — no CS female share results available.\n")
}

# ============================================================================
# FIGURE 8: NAICS 6111 vs 61 Comparison Event Study (NEW)
# ============================================================================

cat("Figure 8: NAICS 6111 vs 61 comparison...\n")

if (!is.null(robust_results$es_broad)) {
  comparison_data <- bind_rows(
    extract_es_data(results$es_emp, "K-12 Schools (NAICS 6111)"),
    extract_es_data(robust_results$es_broad, "All Education (NAICS 61)")
  )

  fig8 <- ggplot(comparison_data, aes(x = event_time, y = estimate, color = outcome, fill = outcome)) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.12) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 2) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
    scale_color_manual(values = c(apep_colors[1], apep_colors[3]), name = NULL) +
    scale_fill_manual(values = c(apep_colors[1], apep_colors[3]), name = NULL) +
    labs(title = "NAICS 6111 (K-12) vs. NAICS 61 (Broad Education) Comparison",
         subtitle = "Callaway-Sant'Anna event study, log employment",
         x = "Quarters Relative to Law Effective Date",
         y = "ATT (Log Employment)",
         caption = "Narrowing to K-12 schools does not alter the null conclusion.") +
    theme_apep() + theme(legend.position = "bottom")

  ggsave("../figures/fig8_naics_comparison.pdf", fig8, width = 10, height = 7)
  ggsave("../figures/fig8_naics_comparison.png", fig8, width = 10, height = 7, dpi = 300)
} else {
  cat("  Skipped — no broad education ES results available.\n")
}

cat("\n=== All figures generated ===\n")
