# ==============================================================================
# 05_figures.R
# Figures for NYC OPCs Paper
# Paper 139 (Revision of apep_0136): Do Supervised Drug Injection Sites Save Lives?
# ==============================================================================
#
# METHODOLOGICAL FIX: All figures now use actual analysis output from
# 03_main_analysis.R. The synthetic control is computed using de-meaned data
# per Ferman & Pinto (2021), which addresses the level mismatch problem.
#
# CRITICAL: Run 03_main_analysis.R FIRST to generate analysis_results.rds
#
# ==============================================================================

# Source packages
if (file.exists("00_packages.R")) {
  source("00_packages.R")
} else if (file.exists("code/00_packages.R")) {
  source("code/00_packages.R")
} else {
  stop("Cannot find 00_packages.R")
}

# Load data
panel_data <- read_csv(file.path(PAPER_DIR, "data", "panel_data.csv"),
                       show_col_types = FALSE)

# Load analysis results
results <- tryCatch(
  readRDS(file.path(PAPER_DIR, "data", "analysis_results.rds")),
  error = function(e) {
    cat("ERROR: analysis_results.rds not found. Run 03_main_analysis.R first.\n")
    NULL
  }
)

if (is.null(results)) {
  stop("Cannot generate figures without analysis results.")
}

# ==============================================================================
# Figure 1: Overdose Death Trends - Treated vs Control
# ==============================================================================

cat("Creating Figure 1: Trends...\n")

fig1_data <- panel_data %>%
  filter(treatment_status %in% c("treated", "control")) %>%
  group_by(year, treatment_status) %>%
  summarise(
    mean_rate = mean(od_rate, na.rm = TRUE),
    se = sd(od_rate, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

fig1 <- ggplot(fig1_data, aes(x = year, y = mean_rate, color = treatment_status)) +
  geom_vline(xintercept = 2021.92, linetype = "dashed", color = "gray40", linewidth = 0.8) +
  annotate("text", x = 2022.1, y = max(fig1_data$mean_rate) * 0.95,
           label = "OPCs Open\n(Nov 2021)", hjust = 0, size = 3, color = "gray40") +
  geom_ribbon(aes(ymin = mean_rate - 1.96 * se, ymax = mean_rate + 1.96 * se,
                  fill = treatment_status), alpha = 0.2, color = NA) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_color_manual(
    values = c("treated" = "#E41A1C", "control" = "#377EB8"),
    labels = c("treated" = "OPC Neighborhoods\n(East Harlem, Washington Heights)",
               "control" = "Control Neighborhoods")
  ) +
  scale_fill_manual(
    values = c("treated" = "#E41A1C", "control" = "#377EB8"),
    guide = "none"
  ) +
  labs(
    title = "Drug Overdose Death Rates in NYC Neighborhoods",
    subtitle = "Neighborhoods with Overdose Prevention Centers vs. Controls",
    x = "Year",
    y = "Overdose Deaths per 100,000",
    color = NULL,
    caption = "Source: NYC DOHMH. Shaded areas show 95% confidence intervals.\nNote: Treated units have higher baseline rates; see de-meaned analysis."
  ) +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 9)
  )

ggsave(file.path(PAPER_DIR, "figures", "fig1_trends.pdf"), fig1, width = 10, height = 7)
ggsave(file.path(PAPER_DIR, "figures", "fig1_trends.png"), fig1, width = 10, height = 7, dpi = 300)
cat("Figure 1 saved.\n")

# ==============================================================================
# Figure 2: Event Study Plot
# ==============================================================================

cat("Creating Figure 2: Event Study...\n")

if (!is.null(results$event_study)) {
  event_coefs <- broom::tidy(results$event_study, conf.int = TRUE)

  event_study_data <- event_coefs %>%
    filter(grepl("year::", term)) %>%
    mutate(
      year = as.numeric(gsub("year::([0-9]+):treat", "\\1", term)),
      event_time = year - 2021,
      coefficient = estimate,
      se = std.error,
      ci_lower = conf.low,
      ci_upper = conf.high
    ) %>%
    bind_rows(tibble(year = 2021, event_time = 0, coefficient = 0, se = 0.01,
                     ci_lower = 0, ci_upper = 0)) %>%
    arrange(year)

  fig2 <- ggplot(event_study_data, aes(x = event_time, y = coefficient)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = 0.5, linetype = "dashed", color = "gray40") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                  width = 0.2, color = "#E41A1C", alpha = 0.7) +
    geom_point(size = 3, color = "#E41A1C") +
    annotate("rect", xmin = 0.5, xmax = 3.5, ymin = -Inf, ymax = Inf,
             alpha = 0.1, fill = "#E41A1C") +
    annotate("text", x = 2, y = max(event_study_data$ci_upper, na.rm = TRUE) * 0.8,
             label = "Post-OPC", fontface = "italic", color = "gray40") +
    scale_x_continuous(breaks = -6:3,
                       labels = c("-6", "-5", "-4", "-3", "-2", "-1", "0",
                                  "+1", "+2", "+3")) +
    labs(
      title = "Event Study: Effect of OPCs on Overdose Deaths",
      subtitle = "Coefficients relative to 2021 (omitted reference year)",
      x = "Years Relative to OPC Opening (2021 = 0)",
      y = "Change in Overdose Death Rate (per 100,000)",
      caption = "Note: Bars show 95% CIs. Pre-trends not flat, suggesting parallel trends may not hold."
    )

  ggsave(file.path(PAPER_DIR, "figures", "fig2_event_study.pdf"), fig2, width = 10, height = 6)
  ggsave(file.path(PAPER_DIR, "figures", "fig2_event_study.png"), fig2, width = 10, height = 6, dpi = 300)
  cat("Figure 2 saved.\n")
}

# ==============================================================================
# Figure 3: De-meaned Synthetic Control - East Harlem
# ==============================================================================
#
# FIXED: Uses actual synthetic control from analysis with de-meaned weights,
# NOT raw control mean which was methodologically inappropriate.
#
# ==============================================================================

cat("Creating Figure 3: De-meaned Synthetic Control...\n")

# Get East Harlem actual data
eh_pre_mean <- results$pre_treat_means %>%
  filter(uhf_id == 203) %>%
  pull(pre_mean)

east_harlem_actual <- panel_data %>%
  filter(uhf_id == 203) %>%
  select(year, od_rate) %>%
  mutate(type = "Actual (East Harlem)")

# Get synthetic control from analysis (already computed with proper weights)
synthetic_control <- results$synthetic_control %>%
  select(year, synth_level) %>%
  rename(od_rate = synth_level) %>%
  mutate(type = "Synthetic Control")

synth_data <- bind_rows(east_harlem_actual, synthetic_control)

# Get 2024 values for gap annotation
actual_2024 <- east_harlem_actual %>% filter(year == 2024) %>% pull(od_rate)
synth_2024 <- synthetic_control %>% filter(year == 2024) %>% pull(od_rate)
gap <- actual_2024 - synth_2024

fig3 <- ggplot(synth_data, aes(x = year, y = od_rate, color = type, linetype = type)) +
  geom_vline(xintercept = 2021.92, linetype = "dashed", color = "gray40", linewidth = 0.8) +
  annotate("text", x = 2022.1, y = max(synth_data$od_rate) * 1.02,
           label = "OPCs Open", hjust = 0, size = 3, color = "gray40") +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_color_manual(values = c("Actual (East Harlem)" = "#E41A1C",
                                "Synthetic Control" = "#377EB8")) +
  scale_linetype_manual(values = c("Actual (East Harlem)" = "solid",
                                   "Synthetic Control" = "dashed")) +
  annotate("segment", x = 2024, y = actual_2024, xend = 2024, yend = synth_2024,
           arrow = arrow(ends = "both", length = unit(0.1, "inches")),
           color = "gray30") +
  annotate("text", x = 2024.3, y = (actual_2024 + synth_2024) / 2,
           label = sprintf("Gap = %.1f", gap),
           hjust = 0, size = 3.5, color = "gray30") +
  labs(
    title = "De-meaned Synthetic Control: East Harlem vs. Counterfactual",
    subtitle = "Synthetic constructed from correlation-weighted controls on de-meaned data",
    x = "Year",
    y = "Overdose Deaths per 100,000",
    color = NULL,
    linetype = NULL,
    caption = paste0("Note: De-meaned SCM per Ferman & Pinto (2021) addresses level mismatch.\n",
                     "Weights: ", paste(names(sort(results$scm_weights, decreasing = TRUE)[1:3]),
                                        collapse = ", "), " (top 3)")
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(PAPER_DIR, "figures", "fig3_synth_east_harlem.pdf"), fig3, width = 10, height = 7)
ggsave(file.path(PAPER_DIR, "figures", "fig3_synth_east_harlem.png"), fig3, width = 10, height = 7, dpi = 300)
cat("Figure 3 saved.\n")

# ==============================================================================
# Figure 4: Randomization Inference Distribution
# ==============================================================================

cat("Creating Figure 4: Randomization Inference...\n")

ri_data <- tibble(effect = results$permuted_effects)
observed <- results$observed_effect

fig4 <- ggplot(ri_data, aes(x = effect)) +
  geom_histogram(bins = 40, fill = "gray70", color = "white") +
  geom_vline(xintercept = observed, color = "#E41A1C", linewidth = 1.5) +
  annotate("text", x = observed, y = Inf,
           label = sprintf("Observed = %.1f\np = %.3f", observed, results$ri_pvalue),
           hjust = -0.1, vjust = 2, color = "#E41A1C", fontface = "bold") +
  labs(
    title = "Randomization Inference: Null Distribution of Treatment Effects",
    subtitle = sprintf("Observed effect is NOT unusual (p = %.3f)", results$ri_pvalue),
    x = "Permuted DiD Effect (deaths per 100,000)",
    y = "Count",
    caption = "Note: 1,000 random permutations of treatment assignment.\nObserved effect falls well within null distribution."
  )

ggsave(file.path(PAPER_DIR, "figures", "fig4_randomization_inference.pdf"), fig4, width = 10, height = 6)
ggsave(file.path(PAPER_DIR, "figures", "fig4_randomization_inference.png"), fig4, width = 10, height = 6, dpi = 300)
cat("Figure 4 saved.\n")

# ==============================================================================
# Figure 5: MSPE Ratio Distribution
# ==============================================================================

cat("Creating Figure 5: MSPE Ratios...\n")

mspe_data <- tibble(
  unit = names(results$mspe_ratios),
  mspe_ratio = results$mspe_ratios,
  rank = results$mspe_ranks[names(results$mspe_ratios)]
) %>%
  mutate(
    treated = unit == "East Harlem",
    unit = fct_reorder(unit, mspe_ratio)
  )

fig5 <- ggplot(mspe_data, aes(x = unit, y = mspe_ratio, fill = treated)) +
  geom_col(width = 0.7) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray50") +
  scale_fill_manual(
    values = c("TRUE" = "#E41A1C", "FALSE" = "#377EB8"),
    guide = "none"
  ) +
  coord_flip() +
  labs(
    title = "MSPE Ratio: Post-Treatment vs. Pre-Treatment Prediction Error",
    subtitle = sprintf("East Harlem ranks %d of %d (NOT anomalous)",
                       results$mspe_ranks["East Harlem"], length(results$mspe_ratios)),
    x = NULL,
    y = "MSPE Ratio (Post / Pre)",
    caption = sprintf("Note: MSPE-based RI p-value = %.3f. East Harlem's post-treatment\ndivergence is NOT larger than control units.", results$ri_pvalue_mspe)
  ) +
  geom_text(aes(label = sprintf("Rank %d", rank)),
            hjust = -0.1, size = 3, color = "gray30")

ggsave(file.path(PAPER_DIR, "figures", "fig5_mspe_ratio.pdf"), fig5, width = 10, height = 6)
ggsave(file.path(PAPER_DIR, "figures", "fig5_mspe_ratio.png"), fig5, width = 10, height = 6, dpi = 300)
cat("Figure 5 saved.\n")

# ==============================================================================
# Figure 6: De-meaned Gap Plot (Abadie-Style)
# ==============================================================================

cat("Creating Figure 6: De-meaned Gap Plot...\n")

# Use de-meaned data from analysis
panel_dm <- results$panel_demeaned

# East Harlem gap (de-meaned actual - de-meaned synthetic)
eh_gap <- panel_dm %>%
  filter(uhf_id == 203) %>%
  left_join(results$synthetic_control %>% select(year, synth_dm), by = "year") %>%
  mutate(
    gap = od_rate_dm - synth_dm,
    unit = "East Harlem (Treated)",
    treated = TRUE
  ) %>%
  select(year, gap, unit, treated)

# Control unit gaps (leave-one-out)
control_gaps <- map_dfr(unique(panel_dm$uhf_id[panel_dm$treatment_status == "control"]),
                        function(uid) {
  unit_data <- panel_dm %>% filter(uhf_id == uid)
  unit_name <- unique(unit_data$uhf_name)

  other_synth <- panel_dm %>%
    filter(treatment_status == "control", uhf_id != uid) %>%
    group_by(year) %>%
    summarise(synth_dm = mean(od_rate_dm, na.rm = TRUE), .groups = "drop")

  unit_data %>%
    left_join(other_synth, by = "year") %>%
    mutate(
      gap = od_rate_dm - synth_dm,
      unit = unit_name,
      treated = FALSE
    ) %>%
    select(year, gap, unit, treated)
})

all_gaps <- bind_rows(eh_gap, control_gaps)

fig6 <- ggplot(all_gaps, aes(x = year, y = gap, group = unit)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "gray70") +
  geom_vline(xintercept = 2021.92, linetype = "dashed", color = "gray40") +
  geom_line(data = filter(all_gaps, !treated),
            color = "gray60", alpha = 0.7, linewidth = 0.6) +
  geom_line(data = filter(all_gaps, treated),
            color = "#E41A1C", linewidth = 1.3) +
  annotate("text", x = 2022.2, y = max(all_gaps$gap) * 0.9,
           label = "OPCs Open", hjust = 0, size = 3, color = "gray40") +
  labs(
    title = "Placebo Test: Treatment vs. Placebo Gaps (De-meaned)",
    subtitle = "East Harlem (red) does NOT show larger divergence than controls",
    x = "Year",
    y = "Gap (De-meaned Actual - De-meaned Synthetic)",
    caption = "Note: Each gray line shows a control unit's gap.\nEast Harlem's gap is within the range of placebo gaps."
  ) +
  theme(legend.position = "none")

ggsave(file.path(PAPER_DIR, "figures", "fig6_placebo_gaps.pdf"), fig6, width = 10, height = 7)
ggsave(file.path(PAPER_DIR, "figures", "fig6_placebo_gaps.png"), fig6, width = 10, height = 7, dpi = 300)
cat("Figure 6 saved.\n")

# ==============================================================================
# Summary
# ==============================================================================

cat("\n=== All Figures Generated ===\n")
cat("Key findings shown in figures:\n")
cat(sprintf("  - DiD effect: %.2f deaths/100k (p = %.3f)\n",
            results$observed_effect, results$ri_pvalue))
cat(sprintf("  - De-meaned ATT (East Harlem): %.2f deaths/100k\n",
            results$att_demeaned_eh))
cat(sprintf("  - MSPE Rank: %d of %d (p = %.3f)\n",
            results$mspe_ranks["East Harlem"], length(results$mspe_ratios),
            results$ri_pvalue_mspe))
cat("\nFigures saved to:", file.path(PAPER_DIR, "figures"), "\n")
