################################################################################
# 06b_qwi_figures.R
# QWI Figures for Salary Transparency Paper
#
# --- Input/Output Provenance ---
# INPUTS:
#   data/qwi_agg.rds, data/qwi_gender_gap.rds, data/qwi_results.rds
#   data/qwi_event_study.rds, data/qwi_cs_earns_es.rds, etc.
# OUTPUTS:
#   figures/fig_qwi_*.pdf
################################################################################

source("code/00_packages.R")

cat("=== Generating QWI Figures ===\n\n")

# Load data
qwi_agg <- readRDS("data/qwi_agg.rds")
qwi_gap <- readRDS("data/qwi_gender_gap.rds")
results <- readRDS("data/qwi_results.rds")
event_studies <- readRDS("data/qwi_event_study.rds")

# ============================================================================
# Figure QWI-1: Quarterly Event Study - Earnings
# ============================================================================

cat("Figure QWI-1: Earnings event study\n")

es_earns <- event_studies$earnings
if (!is.null(es_earns) && nrow(es_earns) > 0) {
  # Trim to reasonable window
  es_earns_plot <- es_earns %>%
    filter(event_time >= -16, event_time <= 12) %>%
    mutate(
      ci_lo = att - 1.96 * se,
      ci_hi = att + 1.96 * se
    )

  p1 <- ggplot(es_earns_plot, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "red", alpha = 0.5) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = color_treated) +
    geom_point(color = color_treated, size = 1.5) +
    geom_line(color = color_treated, linewidth = 0.5) +
    labs(x = "Quarters relative to treatment",
         y = "ATT (log average monthly earnings)") +
    theme_apep()

  ggsave("figures/fig_qwi_event_earns.pdf", p1, width = 8, height = 5.5)
  cat("  Saved figures/fig_qwi_event_earns.pdf\n")
}

# ============================================================================
# Figure QWI-2: Quarterly Event Study - Gender Gap
# ============================================================================

cat("Figure QWI-2: Gender gap event study\n")

es_gap <- event_studies$gender_gap
if (!is.null(es_gap) && nrow(es_gap) > 0) {
  es_gap_plot <- es_gap %>%
    filter(event_time >= -16, event_time <= 12) %>%
    mutate(
      ci_lo = att - 1.96 * se,
      ci_hi = att + 1.96 * se
    )

  p2 <- ggplot(es_gap_plot, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "red", alpha = 0.5) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = color_female) +
    geom_point(color = color_female, size = 1.5) +
    geom_line(color = color_female, linewidth = 0.5) +
    labs(x = "Quarters relative to treatment",
         y = "ATT (male-female log earnings gap)") +
    theme_apep()

  ggsave("figures/fig_qwi_event_gap.pdf", p2, width = 8, height = 5.5)
  cat("  Saved figures/fig_qwi_event_gap.pdf\n")
}

# ============================================================================
# Figure QWI-3: Gender Earnings Gap Trends
# ============================================================================

cat("Figure QWI-3: Gender gap trends\n")

gap_trends <- qwi_gap %>%
  filter(is_aggregate, !is.na(earns_gap)) %>%
  group_by(date, in_sample_treated) %>%
  summarize(
    mean_gap = mean(earns_gap, na.rm = TRUE),
    se_gap = sd(earns_gap, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(group = ifelse(in_sample_treated, "Treated States", "Control States"))

p3 <- ggplot(gap_trends, aes(x = date, y = mean_gap, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1) +
  geom_vline(xintercept = as.Date("2021-01-01"), linetype = "dashed",
             color = "grey50", alpha = 0.7) +
  annotate("text", x = as.Date("2021-06-01"), y = max(gap_trends$mean_gap, na.rm = TRUE),
           label = "First law\n(CO)", size = 3, hjust = 0, color = "grey40") +
  scale_color_manual(values = c("Treated States" = color_treated,
                                 "Control States" = color_control)) +
  labs(x = "", y = "Log earnings gap (male - female)", color = "") +
  theme_apep()

ggsave("figures/fig_qwi_gap_trends.pdf", p3, width = 8, height = 5.5)
cat("  Saved figures/fig_qwi_gap_trends.pdf\n")

# ============================================================================
# Figure QWI-4: Dynamism Coefficient Plot
# ============================================================================

cat("Figure QWI-4: Dynamism coefficient plot\n")

dyn <- results$dynamism
if (length(dyn) > 0) {
  dyn_df <- bind_rows(lapply(dyn, function(x) {
    tibble(
      outcome = x$outcome,
      estimator = x$estimator,
      coef = x$coef,
      se = x$se
    )
  })) %>%
    mutate(
      ci_lo = coef - 1.96 * se,
      ci_hi = coef + 1.96 * se,
      outcome_label = case_when(
        outcome == "hire_rate" ~ "Hiring Rate",
        outcome == "sep_rate" ~ "Separation Rate",
        outcome == "log_hira" ~ "Log Hires",
        outcome == "log_sep" ~ "Log Separations",
        outcome == "net_job_creation_rate" ~ "Net Job Creation Rate",
        TRUE ~ outcome
      ),
      sig = ifelse(abs(coef / se) > 1.96, "p < 0.05", "p >= 0.05")
    )

  p4 <- ggplot(dyn_df %>% filter(estimator == "TWFE"),
               aes(x = coef, y = reorder(outcome_label, coef))) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.2,
                   color = color_treated, linewidth = 0.6) +
    geom_point(aes(shape = sig), color = color_treated, size = 3) +
    scale_shape_manual(values = c("p < 0.05" = 16, "p >= 0.05" = 1)) +
    labs(x = "Treatment effect (TWFE with state and quarter FE)",
         y = "", shape = "Significance") +
    theme_apep() +
    theme(legend.position = "right")

  ggsave("figures/fig_qwi_dynamism.pdf", p4, width = 8, height = 5)
  cat("  Saved figures/fig_qwi_dynamism.pdf\n")
}

# ============================================================================
# Figure QWI-5: Industry Heterogeneity
# ============================================================================

cat("Figure QWI-5: Industry heterogeneity\n")

ind_res <- results$industry
if (length(ind_res) > 0) {
  ind_df <- bind_rows(lapply(ind_res, function(x) {
    tibble(
      industry = x$industry,
      outcome = ifelse(is.null(x$outcome), "earnings", x$outcome),
      coef = x$coef,
      se = x$se
    )
  })) %>%
    mutate(
      ci_lo = coef - 1.96 * se,
      ci_hi = coef + 1.96 * se,
      bargaining = case_when(
        grepl("Finance|Professional", industry) ~ "High-Bargaining",
        grepl("Retail|Accommodation", industry) ~ "Low-Bargaining",
        TRUE ~ "Other"
      )
    )

  # Earnings by industry
  ind_earns <- ind_df %>% filter(outcome == "earnings")
  if (nrow(ind_earns) > 0) {
    p5 <- ggplot(ind_earns, aes(x = coef, y = reorder(industry, coef),
                                 color = bargaining)) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
      geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.2, linewidth = 0.6) +
      geom_point(size = 3) +
      scale_color_manual(values = c("High-Bargaining" = color_treated,
                                     "Low-Bargaining" = color_control)) +
      labs(x = "Treatment effect on log earnings", y = "", color = "") +
      theme_apep() +
      theme(legend.position = "right")

    ggsave("figures/fig_qwi_industry.pdf", p5, width = 8, height = 5)
    cat("  Saved figures/fig_qwi_industry.pdf\n")
  }
}

# ============================================================================
# Figure QWI-6: Earnings Trends (Treated vs Control)
# ============================================================================

cat("Figure QWI-6: Earnings trends\n")

earns_trends <- qwi_agg %>%
  filter(!is.na(log_earns)) %>%
  group_by(date, in_sample_treated) %>%
  summarize(
    mean_earns = mean(log_earns, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(group = ifelse(in_sample_treated, "Treated States", "Control States"))

p6 <- ggplot(earns_trends, aes(x = date, y = mean_earns, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2021-01-01"), linetype = "dashed",
             color = "grey50", alpha = 0.7) +
  scale_color_manual(values = c("Treated States" = color_treated,
                                 "Control States" = color_control)) +
  labs(x = "", y = "Log average quarterly earnings", color = "") +
  theme_apep()

ggsave("figures/fig_qwi_earns_trends.pdf", p6, width = 8, height = 5.5)
cat("  Saved figures/fig_qwi_earns_trends.pdf\n")

# ============================================================================
# Figure QWI Combined: 2-panel (Earnings Trends + Gender Gap Trends)
# Panel (a): Log Quarterly Earnings  |  Panel (b): Gender Earnings Gap
# ============================================================================

cat("Figure QWI Combined: 2-panel earnings + gender gap trends\n")

# Remove annotation from earnings panel for combined figure
p6_panel <- p6 +
  labs(tag = "(a)") +
  theme(legend.position = "none",
        plot.tag = element_text(face = "bold", size = 12))

# Remove annotation from gap panel for combined figure
p3_panel <- p3 +
  labs(tag = "(b)") +
  theme(legend.position = "none",
        plot.tag = element_text(face = "bold", size = 12))

p_qwi_combined <- p6_panel + p3_panel +
  plot_layout(ncol = 2, guides = "collect") &
  theme(legend.position = "bottom")

ggsave("figures/fig3_qwi_combined.pdf", p_qwi_combined, width = 12, height = 5.5)
cat("  Saved figures/fig3_qwi_combined.pdf\n")

cat("\n=== QWI Figures Complete ===\n")
