###############################################################################
# 05_figures.R — Generate all figures
# Paper: Social Insurance Thresholds and Late-Career Underemployment
# APEP-0440
###############################################################################

source("00_packages.R")

cat("=== Loading Data ===\n")
dt <- as.data.table(read_parquet("../data/analysis_employed.parquet"))
results <- readRDS("../data/main_results.rds")

# Color palette
col_main <- "#2c3e50"
col_accent <- "#e74c3c"
col_ss <- "#3498db"
col_mc <- "#e67e22"
col_ci <- "#bdc3c7"

# ============================================================================
# Figure 1: RDD Plots — Overqualification at Both Cutoffs
# ============================================================================
cat("\n=== Figure 1: RDD Plots ===\n")

make_rdd_plot <- function(data, age_var, cutoff, outcome, ylabel, title) {
  # Cell means by age
  cells <- data[, .(
    y = weighted.mean(get(outcome), PWGTP, na.rm = TRUE),
    se = sqrt(sum((PWGTP * (get(outcome) - weighted.mean(get(outcome), PWGTP, na.rm = TRUE)))^2) /
              (sum(PWGTP)^2)) / sqrt(.N),
    n = .N
  ), by = AGEP]

  cells[, age_c := AGEP - cutoff]
  cells[, above := AGEP >= cutoff]

  p <- ggplot(cells, aes(x = AGEP, y = y)) +
    geom_vline(xintercept = cutoff - 0.5, linetype = "dashed",
               color = col_accent, linewidth = 0.8) +
    geom_point(aes(size = n), color = col_main, alpha = 0.7) +
    geom_smooth(data = cells[AGEP < cutoff], method = "lm",
                formula = y ~ x, se = TRUE,
                color = col_main, fill = col_ci, alpha = 0.3) +
    geom_smooth(data = cells[AGEP >= cutoff], method = "lm",
                formula = y ~ x, se = TRUE,
                color = col_main, fill = col_ci, alpha = 0.3) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
    scale_size_continuous(range = c(1.5, 4), guide = "none") +
    labs(x = "Age", y = ylabel, title = title) +
    theme(plot.title = element_text(size = 11))

  return(p)
}

# Panel A: Overqualification at 65
p1a <- make_rdd_plot(
  dt[abs(age_c65) <= 10], "age_c65", 65,
  "overqualified", "Overqualification Rate",
  "A. Medicare Eligibility (Age 65)"
)

# Panel B: Overqualification at 62
p1b <- make_rdd_plot(
  dt[abs(age_c62) <= 10], "age_c62", 62,
  "overqualified", "Overqualification Rate",
  "B. Social Security Eligibility (Age 62)"
)

# Panel C: Part-time at 65
p1c <- make_rdd_plot(
  dt[abs(age_c65) <= 10], "age_c65", 65,
  "part_time", "Part-Time Rate",
  "C. Part-Time Work at Age 65"
)

# Panel D: Part-time at 62
p1d <- make_rdd_plot(
  dt[abs(age_c62) <= 10], "age_c62", 62,
  "part_time", "Part-Time Rate",
  "D. Part-Time Work at Age 62"
)

fig1 <- (p1a + p1b) / (p1c + p1d) +
  plot_annotation(
    title = "Underemployment at Social Insurance Eligibility Thresholds",
    subtitle = "Cell means by age with local linear fits",
    theme = theme(plot.title = element_text(face = "bold", size = 14))
  )

ggsave("../figures/fig1_rdd_main.pdf", fig1, width = 10, height = 8)
cat("  Saved: figures/fig1_rdd_main.pdf\n")

# ============================================================================
# Figure 2: First Stage — Medicare and Insurance Coverage
# ============================================================================
cat("\n=== Figure 2: First Stage ===\n")

cells_ins <- dt[abs(age_c65) <= 10, .(
  medicare_rate = weighted.mean(has_medicare, PWGTP, na.rm = TRUE),
  employer_ins_rate = weighted.mean(has_employer_ins, PWGTP, na.rm = TRUE),
  n = .N
), by = AGEP]

p2a <- ggplot(cells_ins, aes(x = AGEP, y = medicare_rate)) +
  geom_vline(xintercept = 64.5, linetype = "dashed", color = col_accent) +
  geom_point(color = col_mc, size = 3) +
  geom_smooth(data = cells_ins[AGEP < 65], method = "lm",
              color = col_mc, se = TRUE, fill = col_ci, alpha = 0.3) +
  geom_smooth(data = cells_ins[AGEP >= 65], method = "lm",
              color = col_mc, se = TRUE, fill = col_ci, alpha = 0.3) +
  scale_y_continuous(labels = percent_format()) +
  labs(x = "Age", y = "Medicare Coverage Rate",
       title = "A. Medicare Take-Up at Age 65")

p2b <- ggplot(cells_ins, aes(x = AGEP, y = employer_ins_rate)) +
  geom_vline(xintercept = 64.5, linetype = "dashed", color = col_accent) +
  geom_point(color = col_ss, size = 3) +
  geom_smooth(data = cells_ins[AGEP < 65], method = "lm",
              color = col_ss, se = TRUE, fill = col_ci, alpha = 0.3) +
  geom_smooth(data = cells_ins[AGEP >= 65], method = "lm",
              color = col_ss, se = TRUE, fill = col_ci, alpha = 0.3) +
  scale_y_continuous(labels = percent_format()) +
  labs(x = "Age", y = "Employer Insurance Rate",
       title = "B. Employer Insurance at Age 65")

fig2 <- p2a + p2b +
  plot_annotation(title = "First Stage: Insurance Transition at Age 65",
                  theme = theme(plot.title = element_text(face = "bold")))

ggsave("../figures/fig2_first_stage.pdf", fig2, width = 10, height = 5)
cat("  Saved: figures/fig2_first_stage.pdf\n")

# ============================================================================
# Figure 3: Covariate Balance
# ============================================================================
cat("\n=== Figure 3: Covariate Balance ===\n")

cov_vars <- c("female", "has_bachelors", "hispanic")
cov_labels <- c("Female Share", "Bachelor's+ Share", "Hispanic Share")

balance_plots <- list()
for (j in seq_along(cov_vars)) {
  cells_cov <- dt[abs(age_c65) <= 10, .(
    y = weighted.mean(get(cov_vars[j]), PWGTP, na.rm = TRUE)
  ), by = AGEP]

  balance_plots[[j]] <- ggplot(cells_cov, aes(x = AGEP, y = y)) +
    geom_vline(xintercept = 64.5, linetype = "dashed", color = col_accent) +
    geom_point(color = col_main, size = 2.5) +
    geom_smooth(data = cells_cov[AGEP < 65], method = "lm",
                color = col_main, se = TRUE, fill = col_ci, alpha = 0.3) +
    geom_smooth(data = cells_cov[AGEP >= 65], method = "lm",
                color = col_main, se = TRUE, fill = col_ci, alpha = 0.3) +
    scale_y_continuous(labels = percent_format()) +
    labs(x = "Age", y = cov_labels[j],
         title = paste0(LETTERS[j], ". ", cov_labels[j]))
}

fig3 <- wrap_plots(balance_plots, ncol = 3) +
  plot_annotation(title = "Covariate Balance at Age 65 Threshold",
                  theme = theme(plot.title = element_text(face = "bold")))

ggsave("../figures/fig3_balance.pdf", fig3, width = 12, height = 4.5)
cat("  Saved: figures/fig3_balance.pdf\n")

# ============================================================================
# Figure 4: Placebo Cutoffs
# ============================================================================
cat("\n=== Figure 4: Placebo Cutoffs ===\n")

if (file.exists("../data/robustness_placebo.csv")) {
  placebo <- fread("../data/robustness_placebo.csv")

  fig4 <- ggplot(placebo, aes(x = cutoff, y = estimate,
                              color = is_real, shape = is_real)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbar(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se),
                  width = 0.5) +
    geom_point(size = 3) +
    scale_color_manual(values = c("TRUE" = col_accent, "FALSE" = col_main),
                       labels = c("Placebo", "True Threshold"),
                       name = "") +
    scale_shape_manual(values = c("TRUE" = 17, "FALSE" = 16),
                       labels = c("Placebo", "True Threshold"),
                       name = "") +
    labs(x = "Age Cutoff", y = "RDD Estimate (Overqualification)",
         title = "Placebo Cutoff Tests",
         subtitle = "Overqualification effect at real vs. fake age thresholds") +
    theme(legend.position = "bottom")

  ggsave("../figures/fig4_placebo.pdf", fig4, width = 8, height = 5)
  cat("  Saved: figures/fig4_placebo.pdf\n")
} else {
  cat("  Skipping: robustness_placebo.csv not found (run 04_robustness.R first)\n")
}

# ============================================================================
# Figure 5: Bandwidth Sensitivity
# ============================================================================
cat("\n=== Figure 5: Bandwidth Sensitivity ===\n")

if (file.exists("../data/robustness_bandwidth.csv")) {
  bw_data <- fread("../data/robustness_bandwidth.csv")
  bw_data[, cutoff_label := paste("Age", cutoff)]

  fig5 <- ggplot(bw_data, aes(x = bandwidth, y = estimate, color = cutoff_label)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbar(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se),
                  width = 0.3, position = position_dodge(0.4)) +
    geom_point(size = 3, position = position_dodge(0.4)) +
    scale_color_manual(values = c("Age 62" = col_ss, "Age 65" = col_mc),
                       name = "Threshold") +
    labs(x = "Bandwidth (age-years)", y = "RDD Estimate (Overqualification)",
         title = "Bandwidth Sensitivity",
         subtitle = "Overqualification estimates across bandwidth choices") +
    theme(legend.position = "bottom")

  ggsave("../figures/fig5_bandwidth.pdf", fig5, width = 8, height = 5)
  cat("  Saved: figures/fig5_bandwidth.pdf\n")
}

# ============================================================================
# Figure 6: Heterogeneity by Insurance Type
# ============================================================================
cat("\n=== Figure 6: Heterogeneity ===\n")

# By employer insurance status at age 65
for (ins in c(0, 1)) {
  label <- ifelse(ins == 1, "employer", "no_employer")
  sub <- dt[abs(age_c65) <= 10 & has_employer_ins == ins]

  cells_het <- sub[, .(
    y = weighted.mean(overqualified, PWGTP, na.rm = TRUE),
    n = .N
  ), by = AGEP]
  cells_het[, group := ifelse(ins == 1, "Employer Insurance", "No Employer Insurance")]

  if (ins == 0) het_cells <- cells_het else het_cells <- rbind(het_cells, cells_het)
}

fig6 <- ggplot(het_cells, aes(x = AGEP, y = y, color = group)) +
  geom_vline(xintercept = 64.5, linetype = "dashed", color = col_accent) +
  geom_point(size = 2, alpha = 0.7) +
  geom_smooth(data = het_cells[AGEP < 65], method = "lm",
              se = TRUE, alpha = 0.2) +
  geom_smooth(data = het_cells[AGEP >= 65], method = "lm",
              se = TRUE, alpha = 0.2) +
  scale_y_continuous(labels = percent_format()) +
  scale_color_manual(values = c("Employer Insurance" = col_ss,
                                "No Employer Insurance" = col_mc),
                     name = "") +
  labs(x = "Age", y = "Overqualification Rate",
       title = "Overqualification by Insurance Type at Age 65",
       subtitle = "Insurance lock hypothesis: larger discontinuity among employer-insured workers") +
  theme(legend.position = "bottom")

ggsave("../figures/fig6_heterogeneity.pdf", fig6, width = 8, height = 5.5)
cat("  Saved: figures/fig6_heterogeneity.pdf\n")

# ============================================================================
# Figure 7: Year-by-Year Stability
# ============================================================================
cat("\n=== Figure 7: Year-by-Year ===\n")

if (file.exists("../data/robustness_yearly.csv")) {
  yearly <- fread("../data/robustness_yearly.csv")

  fig7 <- ggplot(yearly, aes(x = year, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbar(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se),
                  width = 0.3, color = col_main) +
    geom_point(size = 3, color = col_mc) +
    geom_hline(yintercept = mean(yearly$estimate),
               linetype = "dotted", color = col_accent) +
    labs(x = "Survey Year", y = "RDD Estimate (Overqualification at 65)",
         title = "Year-by-Year Stability of Medicare RDD Estimate",
         subtitle = "Dotted line: pooled estimate") +
    scale_x_continuous(breaks = unique(yearly$year))

  ggsave("../figures/fig7_yearly.pdf", fig7, width = 8, height = 5)
  cat("  Saved: figures/fig7_yearly.pdf\n")
}

# ============================================================================
# Figure 8: Age Density (Employed Sample)
# ============================================================================
cat("\n=== Figure 8: Age Density ===\n")

# Load full population for density comparison
if (file.exists("../data/analysis_full.parquet")) {
  dt_full <- as.data.table(read_parquet("../data/analysis_full.parquet"))

  dens_emp <- dt[, .(n = .N, sample = "Employed"), by = AGEP]
  dens_all <- dt_full[, .(n = .N, sample = "Full Population"), by = AGEP]
  dens <- rbind(dens_emp, dens_all)

  fig8 <- ggplot(dens, aes(x = AGEP, y = n / 1000, fill = sample)) +
    geom_col(position = "dodge", alpha = 0.8) +
    geom_vline(xintercept = 61.5, linetype = "dashed", color = col_ss, linewidth = 0.6) +
    geom_vline(xintercept = 64.5, linetype = "dashed", color = col_mc, linewidth = 0.6) +
    scale_fill_manual(values = c("Employed" = col_main, "Full Population" = col_ci),
                      name = "") +
    labs(x = "Age", y = "Observations (thousands)",
         title = "Sample Density by Age",
         subtitle = "Dashed lines at age 62 (Social Security) and 65 (Medicare)") +
    theme(legend.position = "bottom")

  ggsave("../figures/fig8_density.pdf", fig8, width = 8, height = 5)
  cat("  Saved: figures/fig8_density.pdf\n")
} else {
  cat("  Skipping density figure: analysis_full.parquet not found\n")
}

cat("\n=== All Figures Generated ===\n")
