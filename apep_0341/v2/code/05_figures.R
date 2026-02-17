## ============================================================================
## 05_figures.R — All figure generation
## apep_0341 v2: Medicaid Reimbursement Rates and HCBS Provider Supply
## ============================================================================

source("00_packages.R")

## ---- Load data ----
panel_pc  <- readRDS(file.path(DATA, "did_panel_pc.rds"))
rc        <- readRDS(file.path(DATA, "rate_changes.rds"))
results   <- readRDS(file.path(DATA, "main_results.rds"))
robust    <- readRDS(file.path(DATA, "robust_results.rds"))
month_map <- readRDS(file.path(DATA, "month_map.rds"))

panel_pc[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]

## ============================================================================
## Figure 1: Rate Change Detection — Example States
## ============================================================================

cat("Figure 1: Rate change examples...\n")

treated_states <- rc[treated == TRUE][order(-pct_change)]
example_treated <- head(treated_states, 2)$state
example_control <- head(rc[treated == FALSE], 2)$state
example_states <- c(example_treated, example_control)

fig1_data <- panel_pc[state %in% example_states]
fig1_data[, state_label := paste0(state, ifelse(state %in% example_treated, " (Treated)", " (Control)"))]

treat_lines <- rc[state %in% example_treated, .(state, treat_date)]
treat_lines[, state_label := paste0(state, " (Treated)")]

p1 <- ggplot(fig1_data, aes(x = month_date, y = avg_paid_per_claim)) +
  geom_line(color = apep_colors[1], linewidth = 0.6) +
  geom_vline(data = treat_lines, aes(xintercept = treat_date),
             linetype = "dashed", color = apep_colors[2], linewidth = 0.5) +
  facet_wrap(~state_label, scales = "free_y", ncol = 2) +
  labs(x = NULL, y = "Average Payment per Claim ($)",
       title = "Personal Care Reimbursement Rates by State",
       subtitle = "Dashed lines indicate detected rate increase",
       caption = "Source: T-MSIS Medicaid Provider Spending (2018\u20132024). Personal care codes: T1019, T1020, S5125, S5130.") +
  theme_apep() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")

ggsave(file.path(FIGURES, "fig1_rate_changes.pdf"), p1, width = 8, height = 6)
ggsave(file.path(FIGURES, "fig1_rate_changes.png"), p1, width = 8, height = 6, dpi = 300)

## ============================================================================
## Figure 2: Treatment Timing Distribution
## ============================================================================

cat("Figure 2: Treatment timing distribution...\n")

treat_timing <- rc[treated == TRUE]
treat_timing[, treat_quarter := paste0(year(treat_date), " Q", ceiling(month(treat_date) / 3))]

## v2: Shade ARPA era
p2 <- ggplot(treat_timing, aes(x = treat_date)) +
  annotate("rect", xmin = as.Date("2021-04-01"), xmax = as.Date("2024-12-31"),
           ymin = -Inf, ymax = Inf, fill = apep_colors[6], alpha = 0.15) +
  annotate("text", x = as.Date("2022-06-01"), y = Inf,
           label = "ARPA Era", vjust = 1.5, size = 3, color = "grey40") +
  geom_histogram(binwidth = 90, fill = apep_colors[1], color = "white", alpha = 0.8) +
  labs(x = "Date of Rate Increase", y = "Number of States",
       title = "Distribution of HCBS Rate Increase Timing",
       subtitle = "Shaded region: post-ARPA period (April 2021 onward)",
       caption = "Source: Authors' calculations from T-MSIS payment data.") +
  theme_apep() +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y")

ggsave(file.path(FIGURES, "fig2_treatment_timing.pdf"), p2, width = 7, height = 5)
ggsave(file.path(FIGURES, "fig2_treatment_timing.png"), p2, width = 7, height = 5, dpi = 300)

## ============================================================================
## Figure 3: Event Study — CS-DiD (Provider Counts)
## ============================================================================

cat("Figure 3: CS-DiD event study (providers)...\n")

if (!is.null(results$es_providers)) {
  es <- results$es_providers
  es_dt <- data.table(
    rel_time = es$egt,
    att      = es$att.egt,
    se       = es$se.egt
  )
  es_dt[, ci_lo := att - 1.96 * se]
  es_dt[, ci_hi := att + 1.96 * se]

  p3 <- ggplot(es_dt, aes(x = rel_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = apep_colors[2]) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = apep_colors[1], alpha = 0.15) +
    geom_point(color = apep_colors[1], size = 2) +
    geom_line(color = apep_colors[1], linewidth = 0.5) +
    labs(x = "Quarters Relative to Rate Increase",
         y = "ATT (Log Provider Count)",
         title = "Event Study: Provider Participation After Rate Increase",
         subtitle = "Callaway and Sant'Anna (2021) estimator; 95% pointwise CIs",
         caption = "Source: T-MSIS. Never-treated states as comparison group.") +
    theme_apep()

  ggsave(file.path(FIGURES, "fig3_es_providers.pdf"), p3, width = 8, height = 5.5)
  ggsave(file.path(FIGURES, "fig3_es_providers.png"), p3, width = 8, height = 5.5, dpi = 300)
}

## ============================================================================
## Figure 4: Event Study — CS-DiD (Beneficiaries Served)
## ============================================================================

cat("Figure 4: CS-DiD event study (beneficiaries)...\n")

if (!is.null(results$es_benes)) {
  es_b <- results$es_benes
  es_b_dt <- data.table(
    rel_time = es_b$egt,
    att      = es_b$att.egt,
    se       = es_b$se.egt
  )
  es_b_dt[, ci_lo := att - 1.96 * se]
  es_b_dt[, ci_hi := att + 1.96 * se]

  p4 <- ggplot(es_b_dt, aes(x = rel_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = apep_colors[2]) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = apep_colors[3], alpha = 0.15) +
    geom_point(color = apep_colors[3], size = 2) +
    geom_line(color = apep_colors[3], linewidth = 0.5) +
    labs(x = "Quarters Relative to Rate Increase",
         y = "ATT (Log Beneficiaries Served)",
         title = "Event Study: Beneficiaries Served After Rate Increase",
         subtitle = "Callaway and Sant'Anna (2021) estimator; 95% pointwise CIs",
         caption = "Source: T-MSIS. Never-treated states as comparison group.") +
    theme_apep()

  ggsave(file.path(FIGURES, "fig4_es_beneficiaries.pdf"), p4, width = 8, height = 5.5)
  ggsave(file.path(FIGURES, "fig4_es_beneficiaries.png"), p4, width = 8, height = 5.5, dpi = 300)
}

## ============================================================================
## Figure 5: Treated vs. Control Mean Trends
## ============================================================================

cat("Figure 5: Parallel trends...\n")

panel_pc[, group := ifelse(treated, "Treated", "Never-Treated")]

trends <- panel_pc[, .(
  mean_providers = mean(n_providers),
  mean_benes     = mean(total_benes),
  mean_claims    = mean(total_claims)
), by = .(month_date, group)]

# Normalize to index = 100 at January 2018 baseline
baseline <- trends[month_date == min(month_date), .(group, base_prov = mean_providers)]
trends <- merge(trends, baseline, by = "group")
trends[, index_providers := (mean_providers / base_prov) * 100]

p5 <- ggplot(trends, aes(x = month_date, y = index_providers, color = group)) +
  geom_line(linewidth = 0.7) +
  geom_vline(xintercept = as.Date("2021-04-01"), linetype = "dashed",
             color = "grey40", linewidth = 0.4) +
  annotate("text", x = as.Date("2021-04-01"), y = Inf,
           label = "ARPA Enacted", hjust = -0.1, vjust = 1.5, size = 3, color = "grey40") +
  scale_color_manual(values = c("Treated" = apep_colors[1], "Never-Treated" = apep_colors[2])) +
  labs(x = NULL, y = "Provider Count Index (January 2018 = 100)",
       color = NULL,
       title = "Personal Care Provider Counts: Treated vs. Never-Treated States",
       subtitle = "Indexed to January 2018 baseline; mean across states by treatment group",
       caption = "Source: T-MSIS. Treatment defined by detected rate increases in personal care codes.") +
  theme_apep() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y",
               limits = c(as.Date("2018-01-01"), as.Date("2024-09-01")))

ggsave(file.path(FIGURES, "fig5_parallel_trends.pdf"), p5, width = 8, height = 5.5)
ggsave(file.path(FIGURES, "fig5_parallel_trends.png"), p5, width = 8, height = 5.5, dpi = 300)

## ============================================================================
## Figure 6: Heterogeneity by Provider Type
## ============================================================================

cat("Figure 6: Heterogeneity...\n")

het_dt <- data.table(
  type = c("All Providers", "Individual (Type 1)", "Organization (Type 2)", "Sole Proprietors"),
  coef = c(coef(results$twfe_providers)["post_treat"],
           coef(robust$het_indiv)["post_treat"],
           coef(robust$het_org)["post_treat"],
           coef(robust$het_sole)["post_treat"]),
  se   = c(se(results$twfe_providers)["post_treat"],
           se(robust$het_indiv)["post_treat"],
           se(robust$het_org)["post_treat"],
           se(robust$het_sole)["post_treat"])
)
het_dt[, ci_lo := coef - 1.96 * se]
het_dt[, ci_hi := coef + 1.96 * se]
het_dt[, type := factor(type, levels = rev(type))]

p6 <- ggplot(het_dt, aes(x = coef, y = type)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.2,
                 color = apep_colors[1], linewidth = 0.6) +
  geom_point(color = apep_colors[1], size = 3) +
  labs(x = "TWFE Coefficient (Log Provider Count)", y = NULL,
       title = "Heterogeneous Effects by Provider Type",
       subtitle = "TWFE estimates with 95% CIs, clustered at state level",
       caption = "Source: T-MSIS + NPPES. Entity type from NPPES registration.") +
  theme_apep()

ggsave(file.path(FIGURES, "fig6_heterogeneity.pdf"), p6, width = 7, height = 4.5)
ggsave(file.path(FIGURES, "fig6_heterogeneity.png"), p6, width = 7, height = 4.5, dpi = 300)

## ============================================================================
## Figure 7: Randomization Inference Distribution
## ============================================================================

cat("Figure 7: Randomization inference...\n")

ri_dt <- data.table(coef = robust$ri_distribution[!is.na(robust$ri_distribution)])

p7 <- ggplot(ri_dt, aes(x = coef)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = robust$ri_observed, color = apep_colors[2],
             linewidth = 0.8, linetype = "solid") +
  annotate("text", x = robust$ri_observed, y = Inf,
           label = sprintf("Observed = %.3f\nRI p = %.3f",
                           robust$ri_observed, robust$ri_pvalue),
           hjust = -0.1, vjust = 1.5, size = 3.5) +
  labs(x = "Permuted Treatment Effect", y = "Frequency",
       title = "Randomization Inference: Provider Count Effect",
       subtitle = "Distribution of placebo treatment effects (1,000 permutations)",
       caption = "Two-sided p-value: fraction of |permuted| \u2265 |observed|.") +
  theme_apep()

ggsave(file.path(FIGURES, "fig7_ri_distribution.pdf"), p7, width = 7, height = 5)
ggsave(file.path(FIGURES, "fig7_ri_distribution.png"), p7, width = 7, height = 5, dpi = 300)

## ============================================================================
## Figure 8: Dose-Response Scatter
## ============================================================================

cat("Figure 8: Dose-response...\n")

post_means <- panel_pc[treated == TRUE & post_treat == 1, .(
  mean_log_prov = mean(log_providers),
  mean_log_benes = mean(log_benes)
), by = .(state)]
post_means <- merge(post_means, rc[treated == TRUE, .(state, pct_change)], by = "state")

# Exclude Wyoming outlier (1,422%) for visual clarity
post_means_plot <- post_means[pct_change * 100 <= 300]

p8 <- ggplot(post_means_plot, aes(x = pct_change * 100, y = mean_log_prov)) +
  geom_point(color = apep_colors[1], size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = apep_colors[1],
              fill = apep_colors[1], alpha = 0.1, linewidth = 0.6) +
  labs(x = "Rate Increase Magnitude (%)",
       y = "Mean Log Provider Count (Post-Treatment)",
       title = "Dose-Response: Rate Increase Size and Provider Supply",
       subtitle = "Each point is a treated state; line shows OLS fit with 95% CI\nWyoming excluded (1,422% increase) for visual clarity",
       caption = "Source: T-MSIS. Rate increase detected from payment per claim data.") +
  theme_apep()

ggsave(file.path(FIGURES, "fig8_dose_response.pdf"), p8, width = 7, height = 5.5)
ggsave(file.path(FIGURES, "fig8_dose_response.png"), p8, width = 7, height = 5.5, dpi = 300)

## ============================================================================
## Figure 9 (v2): Consolidation Mechanism — Org Share Over Time
## ============================================================================

cat("Figure 9: Consolidation mechanism...\n")

mech_trends <- panel_pc[, .(
  mean_org_share = mean(org_share, na.rm = TRUE),
  mean_claims_per_prov = mean(claims_per_provider_raw, na.rm = TRUE)
), by = .(month_date, group)]

p9 <- ggplot(mech_trends, aes(x = month_date, y = mean_org_share, color = group)) +
  geom_line(linewidth = 0.7) +
  geom_vline(xintercept = as.Date("2021-04-01"), linetype = "dashed",
             color = "grey40", linewidth = 0.4) +
  scale_color_manual(values = c("Treated" = apep_colors[1], "Never-Treated" = apep_colors[2])) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(x = NULL, y = "Organization Share of Billing NPIs",
       color = NULL,
       title = "Organizational Billing Share: Treated vs. Never-Treated States",
       subtitle = "Share of unique billing NPIs classified as Type 2 (organizations)",
       caption = "Source: T-MSIS + NPPES. Vertical line marks ARPA enactment.") +
  theme_apep() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")

ggsave(file.path(FIGURES, "fig9_consolidation.pdf"), p9, width = 8, height = 5.5)
ggsave(file.path(FIGURES, "fig9_consolidation.png"), p9, width = 8, height = 5.5, dpi = 300)

cat("\n=== All figures generated ===\n")
cat(sprintf("Saved %d figures to %s\n", length(list.files(FIGURES, pattern = "\\.pdf$")), FIGURES))
