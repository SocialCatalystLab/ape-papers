###############################################################################
# 05_figures.R — Publication-quality figures
# APEP-0372: Minimum Wage Spillovers to College Graduate Earnings
###############################################################################

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

df <- readRDS(file.path(data_dir, "analysis_data.rds"))
df_cip <- readRDS(file.path(data_dir, "analysis_cip.rds"))
controls <- readRDS(file.path(data_dir, "controls_panel.rds"))

###############################################################################
# Figure 1: MW Variation Across States and Cohorts
###############################################################################

cat("=== Figure 1: MW Variation ===\n")

# Build complete state FIPS lookup
all_state_abbr <- data.frame(
  fips = sprintf("%02d", c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56)),
  abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  stringsAsFactors = FALSE
)

mw_plot_data <- controls %>%
  left_join(all_state_abbr, by = c("state_fips" = "fips")) %>%
  filter(cohort != 0, !is.na(abbr))

p1a <- ggplot(mw_plot_data, aes(x = factor(cohort), y = mw_avg, group = state_fips)) +
  geom_line(alpha = 0.3, color = "grey50") +
  geom_point(aes(color = above_federal == 1), size = 1.5, alpha = 0.7) +
  scale_color_manual(
    values = c("TRUE" = apep_colors[1], "FALSE" = apep_colors[2]),
    labels = c("At Federal", "Above Federal"),
    name = ""
  ) +
  labs(
    title = "A. State Minimum Wage by Graduation Cohort",
    x = "Graduation Cohort",
    y = "Effective Minimum Wage ($/hr)"
  ) +
  theme_apep()

# Panel B: Distribution of MW changes
mw_changes <- mw_plot_data %>%
  group_by(state_fips) %>%
  arrange(cohort) %>%
  summarise(
    total_change = last(mw_avg) - first(mw_avg),
    abbr = first(abbr),
    .groups = "drop"
  ) %>%
  arrange(total_change)

p1b <- ggplot(mw_changes, aes(x = reorder(abbr, total_change), y = total_change)) +
  geom_col(aes(fill = total_change > median(total_change, na.rm = TRUE)),
           show.legend = FALSE) +
  scale_fill_manual(values = c(apep_colors[2], apep_colors[1])) +
  coord_flip() +
  labs(
    title = "B. Total MW Change by State (2001-2019)",
    x = "",
    y = "Change in Effective MW ($/hr)"
  ) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 7))

p1 <- p1a / p1b + plot_layout(heights = c(1, 1.5))
ggsave(file.path(fig_dir, "fig1_mw_variation.pdf"), p1, width = 8, height = 10)
cat("  Saved fig1_mw_variation.pdf\n")

###############################################################################
# Figure 2: Graduate Earnings vs MW (motivating scatter)
###############################################################################

cat("=== Figure 2: Earnings vs MW ===\n")

# State-level relationship for bachelor's
df_scatter <- df %>%
  filter(degree_group == "Bachelor's", !is.na(y1_p25)) %>%
  group_by(state_fips, cohort) %>%
  summarise(
    mean_p25 = mean(y1_p25, na.rm = TRUE),
    mean_p50 = mean(y1_p50, na.rm = TRUE),
    mean_p75 = mean(y1_p75, na.rm = TRUE),
    mw_annual = first(mw_annual),
    n_inst = n(),
    .groups = "drop"
  )

p2 <- ggplot(df_scatter, aes(x = mw_annual / 1000, y = mean_p25 / 1000)) +
  geom_point(aes(size = n_inst, color = factor(cohort)), alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, color = "black", linewidth = 0.8) +
  scale_color_brewer(palette = "YlOrRd", name = "Cohort") +
  scale_size_continuous(range = c(1, 5), name = "N Institutions") +
  labs(
    title = "Bachelor's P25 Earnings vs. Annualized Minimum Wage",
    subtitle = "State-cohort means, 2001-2019",
    x = "Annualized Minimum Wage ($000s)",
    y = "Mean P25 First-Year Earnings ($000s)"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_earnings_vs_mw.pdf"), p2, width = 8, height = 6)
cat("  Saved fig2_earnings_vs_mw.pdf\n")

###############################################################################
# Figure 3: Coefficient Gradient (P25 → P50 → P75)
###############################################################################

cat("=== Figure 3: Coefficient Gradient ===\n")

results <- readRDS(file.path(data_dir, "regression_results.rds"))

# Extract coefficients from main regressions (with controls)
gradient_data <- data.frame(
  percentile = factor(rep(c("P25", "P50", "P75"), 3),
                      levels = c("P25", "P50", "P75")),
  horizon = rep(c("1 Year", "5 Year", "10 Year"), each = 3),
  beta = NA_real_,
  se = NA_real_,
  stringsAsFactors = FALSE
)

# Fill from horizon_results
for (h in c("y1", "y5", "y10")) {
  h_label <- switch(h, y1 = "1 Year", y5 = "5 Year", y10 = "10 Year")
  for (p in c("p25", "p50", "p75")) {
    p_label <- toupper(p)
    key <- paste(h, p, sep = "_")
    if (key %in% names(results$horizon_results)) {
      r <- results$horizon_results[[key]]
      idx <- which(gradient_data$percentile == p_label & gradient_data$horizon == h_label)
      gradient_data$beta[idx] <- r$beta
      gradient_data$se[idx] <- r$se
    }
  }
}

gradient_data <- gradient_data %>%
  filter(!is.na(beta)) %>%
  mutate(
    ci_lo = beta - 1.96 * se,
    ci_hi = beta + 1.96 * se,
    horizon = factor(horizon, levels = c("1 Year", "5 Year", "10 Year"))
  )

p3 <- ggplot(gradient_data, aes(x = percentile, y = beta, color = horizon, group = horizon)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_point(position = position_dodge(width = 0.3), size = 3) +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                position = position_dodge(width = 0.3), width = 0.2) +
  geom_line(position = position_dodge(width = 0.3), linewidth = 0.5) +
  scale_color_manual(values = apep_colors[1:3], name = "Horizon") +
  labs(
    title = "MW Elasticity by Earnings Percentile and Horizon",
    subtitle = "Bachelor's degree graduates, institution FE + cohort FE + state controls",
    x = "Earnings Percentile",
    y = expression(paste("Elasticity ", (beta), " of log earnings w.r.t. log MW"))
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_gradient.pdf"), p3, width = 8, height = 6)
cat("  Saved fig3_gradient.pdf\n")

###############################################################################
# Figure 4: Heterogeneity by Degree Level
###############################################################################

cat("=== Figure 4: Degree Level Heterogeneity ===\n")

degree_plot <- bind_rows(lapply(names(results$degree_results), function(dg) {
  r <- results$degree_results[[dg]]
  data.frame(
    degree = r$degree,
    percentile = c("P25", "P50", "P75"),
    beta = c(r$p25_beta, r$p50_beta, r$p75_beta),
    se = c(r$p25_se, r$p50_se, r$p75_se),
    n = r$n,
    stringsAsFactors = FALSE
  )
})) %>%
  filter(!is.na(beta)) %>%
  mutate(
    ci_lo = beta - 1.96 * se,
    ci_hi = beta + 1.96 * se,
    degree = factor(degree, levels = c("Certificate", "Associate", "Bachelor's")),
    percentile = factor(percentile, levels = c("P25", "P50", "P75"))
  )

p4 <- ggplot(degree_plot, aes(x = percentile, y = beta, color = degree, group = degree)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_point(position = position_dodge(width = 0.3), size = 3) +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                position = position_dodge(width = 0.3), width = 0.2) +
  scale_color_manual(values = apep_colors[1:3], name = "Degree Level") +
  labs(
    title = "MW Elasticity by Degree Level and Percentile",
    subtitle = "First-year earnings, institution FE + cohort FE + state controls",
    x = "Earnings Percentile",
    y = expression(paste("Elasticity ", (beta)))
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_degree_het.pdf"), p4, width = 8, height = 6)
cat("  Saved fig4_degree_het.pdf\n")

###############################################################################
# Figure 5: CIP-Level Heterogeneity (Bachelor's)
###############################################################################

cat("=== Figure 5: CIP Heterogeneity ===\n")

cip_plot <- bind_rows(lapply(names(results$cip_results), function(wg) {
  r <- results$cip_results[[wg]]
  data.frame(
    group = r$group,
    beta = r$beta,
    se = r$se,
    n = r$n,
    stringsAsFactors = FALSE
  )
})) %>%
  mutate(
    ci_lo = beta - 1.96 * se,
    ci_hi = beta + 1.96 * se,
    group = factor(group, levels = c("Low-wage", "Mid-wage", "High-wage"))
  )

if (nrow(cip_plot) > 0) {
  p5 <- ggplot(cip_plot, aes(x = group, y = beta, color = group)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
    geom_point(size = 4) +
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.2) +
    scale_color_manual(values = apep_colors[1:3]) +
    labs(
      title = "MW Elasticity by Field Wage Group (Bachelor's, P25)",
      subtitle = "Low-wage: Education, Humanities, Arts; High-wage: CS, Engineering, Business",
      x = "Field of Study Group",
      y = expression(paste("Elasticity ", (beta), " on P25 first-year earnings"))
    ) +
    theme_apep() +
    theme(legend.position = "none")

  ggsave(file.path(fig_dir, "fig5_cip_het.pdf"), p5, width = 7, height = 5)
  cat("  Saved fig5_cip_het.pdf\n")
}

###############################################################################
# Figure 6: Jackknife Stability
###############################################################################

cat("=== Figure 6: Jackknife ===\n")

rob_results <- readRDS(file.path(data_dir, "robustness_results.rds"))

state_fips_df <- readRDS(file.path(data_dir, "state_fips.rds"))

jk_data <- data.frame(
  state_fips = rob_results$jackknife_states,
  beta = rob_results$jackknife_betas,
  stringsAsFactors = FALSE
) %>%
  filter(!is.na(beta)) %>%
  left_join(state_fips_df, by = c("state_fips" = "fips")) %>%
  arrange(beta)

full_beta <- coef(feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
                        data = df %>% filter(degree_group == "Bachelor's", !is.na(ln_y1_p25)),
                        cluster = "state_fips"))["ln_mw"]

p6 <- ggplot(jk_data, aes(x = reorder(abbr, beta), y = beta)) +
  geom_hline(yintercept = full_beta, color = apep_colors[1], linewidth = 0.8,
             linetype = "solid") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_point(size = 2, color = apep_colors[2]) +
  coord_flip() +
  labs(
    title = "Jackknife Sensitivity: Dropping One State at a Time",
    subtitle = sprintf("Blue line = full sample estimate (%.4f)", full_beta),
    x = "State Dropped",
    y = expression(paste("Estimated ", beta, " on ln(MW)"))
  ) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 7))

ggsave(file.path(fig_dir, "fig6_jackknife.pdf"), p6, width = 7, height = 9)
cat("  Saved fig6_jackknife.pdf\n")

###############################################################################
# Figure 7: Earnings Trends by Degree Level
###############################################################################

cat("=== Figure 7: Earnings Trends ===\n")

trends <- df %>%
  filter(degree_group %in% c("Certificate", "Associate", "Bachelor's"),
         !is.na(y1_p25)) %>%
  group_by(degree_group, cohort) %>%
  summarise(
    mean_p25 = mean(y1_p25, na.rm = TRUE),
    mean_p50 = mean(y1_p50, na.rm = TRUE),
    mean_p75 = mean(y1_p75, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = starts_with("mean_"),
               names_to = "percentile",
               values_to = "earnings") %>%
  mutate(
    percentile = gsub("mean_", "", percentile) %>% toupper(),
    percentile = factor(percentile, levels = c("P25", "P50", "P75"))
  )

p7 <- ggplot(trends, aes(x = cohort, y = earnings / 1000,
                          color = percentile, group = percentile)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  facet_wrap(~ degree_group, scales = "free_y") +
  scale_color_manual(values = apep_colors[1:3], name = "Percentile") +
  labs(
    title = "First-Year Earnings Trends by Degree Level and Percentile",
    subtitle = "Census PSEO Time Series, 2023 dollars",
    x = "Graduation Cohort",
    y = "Mean Earnings ($000s)"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig7_trends.pdf"), p7, width = 10, height = 5)
cat("  Saved fig7_trends.pdf\n")

cat("\nAll figures saved.\n")
