# ==============================================================================
# 05_figures.R
# State Minimum Wage Increases and Young Adult Household Formation
# Purpose: Generate publication-quality figures for the paper
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================================\n")
cat("  05_figures.R: Generating figures\n")
cat("========================================================\n\n")

# ==============================================================================
# SECTION 1: Load data and results
# ==============================================================================

cat("--- Loading data and saved model objects ---\n")

panel <- read.csv(file.path(DATA_DIR, "analysis_panel.csv"),
                  stringsAsFactors = FALSE)

# Main CS-DiD objects
cs_out       <- readRDS(file.path(DATA_DIR, "cs_out.rds"))
es           <- readRDS(file.path(DATA_DIR, "cs_event_study.rds"))
att_overall  <- readRDS(file.path(DATA_DIR, "cs_overall_att.rds"))

# Robustness objects (load with error handling)
load_safe <- function(path) {
  tryCatch(readRDS(path), error = function(e) NULL)
}

bacon_out      <- load_safe(file.path(DATA_DIR, "bacon_decomposition.rds"))
honest_results <- load_safe(file.path(DATA_DIR, "honest_did_results.rds"))
region_results <- load_safe(file.path(DATA_DIR, "region_heterogeneity.rds"))
es_nyt         <- load_safe(file.path(DATA_DIR, "cs_nyt_es.rds"))
es_indep       <- load_safe(file.path(DATA_DIR, "cs_indep_es.rds"))

cat("  Data and models loaded.\n\n")

# Standard figure dimensions
FIG_W <- 7
FIG_H <- 5

# ==============================================================================
# FIGURE 1: Treatment rollout
# ==============================================================================

cat("--- Figure 1: Treatment rollout ---\n")

rollout <- panel %>%
  filter(first_treat > 0) %>%
  select(state_fips, state_abbr, first_treat) %>%
  distinct()

rollout_counts <- rollout %>%
  count(first_treat, name = "n_states")

# Also create a cumulative count
rollout_counts <- rollout_counts %>%
  arrange(first_treat) %>%
  mutate(cumulative = cumsum(n_states))

p1 <- ggplot(rollout_counts, aes(x = first_treat, y = n_states)) +
  geom_col(fill = apep_colors[1], width = 0.7, alpha = 0.85) +
  geom_text(aes(label = n_states), vjust = -0.5, size = 3.5, fontface = "bold",
            color = "grey30") +
  geom_line(aes(y = cumulative), color = apep_colors[2], linewidth = 0.9,
            linetype = "dashed") +
  geom_point(aes(y = cumulative), color = apep_colors[2], size = 2.5) +
  scale_x_continuous(breaks = rollout_counts$first_treat) +
  scale_y_continuous(
    name = "Number of Newly Treated States",
    sec.axis = sec_axis(~., name = "Cumulative Treated States"),
    expand = expansion(mult = c(0, 0.15))
  ) +
  labs(
    title = "Treatment Rollout: State MW Exceeds Federal + $1.00",
    subtitle = "Bars = newly treated states; dashed line = cumulative total",
    x = "Year of First Treatment"
  ) +
  theme_apep() +
  theme(
    axis.title.y.right = element_text(color = apep_colors[2]),
    axis.text.y.right  = element_text(color = apep_colors[2])
  )

ggsave(file.path(FIG_DIR, "fig_treatment_rollout.pdf"), p1,
       width = FIG_W, height = FIG_H, device = "pdf")
cat("  Saved: fig_treatment_rollout.pdf\n\n")

# ==============================================================================
# FIGURE 2: Raw trends — treated vs. control
# ==============================================================================

cat("--- Figure 2: Raw trends ---\n")

panel <- panel %>%
  mutate(group = ifelse(first_treat > 0, "Treated (ever)", "Never-treated"))

trends <- panel %>%
  group_by(year, group) %>%
  summarise(
    mean_parents = mean(pct_with_parents, na.rm = TRUE),
    se_parents   = sd(pct_with_parents, na.rm = TRUE) / sqrt(n()),
    mean_indep   = mean(pct_independent, na.rm = TRUE),
    se_indep     = sd(pct_independent, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

# Median treatment year for reference line
median_treat <- panel %>%
  filter(first_treat > 0) %>%
  select(state_fips, first_treat) %>%
  distinct() %>%
  summarise(med = median(first_treat)) %>%
  pull(med)

# Panel A: Living with parents
p2a <- ggplot(trends, aes(x = year, y = mean_parents,
                           color = group, shape = group)) +
  geom_ribbon(aes(ymin = mean_parents - 1.96 * se_parents,
                  ymax = mean_parents + 1.96 * se_parents,
                  fill = group), alpha = 0.12, color = NA) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2.2) +
  geom_vline(xintercept = median_treat, linetype = "dashed",
             color = "grey50", linewidth = 0.5) +
  annotate("text", x = median_treat + 0.3, y = Inf,
           label = paste0("Median treat. year (", median_treat, ")"),
           hjust = 0, vjust = 1.5, size = 3, color = "grey50") +
  scale_color_manual(values = c("Treated (ever)" = apep_colors[1],
                                "Never-treated"  = apep_colors[2])) +
  scale_fill_manual(values = c("Treated (ever)" = apep_colors[1],
                               "Never-treated"  = apep_colors[2])) +
  scale_shape_manual(values = c("Treated (ever)" = 16,
                                "Never-treated"  = 17)) +
  labs(
    title = "A: Percent of Young Adults (18\u201334) Living with Parents",
    x = "Year", y = "Percent (%)",
    color = NULL, fill = NULL, shape = NULL
  ) +
  theme_apep()

# Panel B: Independent living
p2b <- ggplot(trends, aes(x = year, y = mean_indep,
                           color = group, shape = group)) +
  geom_ribbon(aes(ymin = mean_indep - 1.96 * se_indep,
                  ymax = mean_indep + 1.96 * se_indep,
                  fill = group), alpha = 0.12, color = NA) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2.2) +
  geom_vline(xintercept = median_treat, linetype = "dashed",
             color = "grey50", linewidth = 0.5) +
  scale_color_manual(values = c("Treated (ever)" = apep_colors[1],
                                "Never-treated"  = apep_colors[2])) +
  scale_fill_manual(values = c("Treated (ever)" = apep_colors[1],
                               "Never-treated"  = apep_colors[2])) +
  scale_shape_manual(values = c("Treated (ever)" = 16,
                                "Never-treated"  = 17)) +
  labs(
    title = "B: Percent of Young Adults (18\u201334) Living Independently",
    x = "Year", y = "Percent (%)",
    color = NULL, fill = NULL, shape = NULL
  ) +
  theme_apep()

p2 <- p2a / p2b +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig_raw_trends.pdf"), p2,
       width = FIG_W, height = 9, device = "pdf")
cat("  Saved: fig_raw_trends.pdf\n\n")

# ==============================================================================
# FIGURE 3: CS-DiD event study
# ==============================================================================

cat("--- Figure 3: CS-DiD event study ---\n")

es_df <- data.frame(
  event_time = es$egt,
  att        = es$att.egt,
  se         = es$se.egt,
  ci_lo      = es$att.egt - 1.96 * es$se.egt,
  ci_hi      = es$att.egt + 1.96 * es$se.egt
)

# Mark reference period (t = -1)
ref_row <- data.frame(event_time = -1, att = 0, se = 0, ci_lo = 0, ci_hi = 0)
if (!(-1 %in% es_df$event_time)) {
  es_df <- bind_rows(es_df, ref_row) %>% arrange(event_time)
}

p3 <- ggplot(es_df, aes(x = event_time, y = att)) +
  # CI ribbon
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
              fill = apep_colors[1], alpha = 0.15) +
  # Zero reference line
  geom_hline(yintercept = 0, linetype = "solid", color = "grey50",
             linewidth = 0.4) +
  # Vertical line at t = -1
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey60",
             linewidth = 0.4) +
  # Point estimates and CIs
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                width = 0.2, color = apep_colors[1], linewidth = 0.5) +
  geom_point(size = 2.5, color = apep_colors[1], fill = "white", shape = 21,
             stroke = 1) +
  # Highlight t = -1 reference point
  geom_point(data = es_df %>% filter(event_time == -1),
             size = 3, color = apep_colors[2], shape = 18) +
  # Labels
  annotate("text", x = -0.5, y = max(es_df$ci_hi, na.rm = TRUE) * 0.9,
           label = "Treatment onset", hjust = 1.1, size = 3,
           color = "grey50", fontface = "italic") +
  scale_x_continuous(breaks = seq(min(es_df$event_time), max(es_df$event_time), 1)) +
  labs(
    title = "Event Study: Effect of Minimum Wage Increases on Parental Co-residence",
    subtitle = paste0("Callaway & Sant'Anna (2021) | Overall ATT = ",
                      sprintf("%.3f", att_overall$overall.att),
                      " (SE = ", sprintf("%.3f", att_overall$overall.se), ")"),
    x = "Event Time (Years Relative to Treatment)",
    y = "ATT: Percentage Point Change in Living with Parents",
    caption = "Notes: 95% confidence intervals based on clustered bootstrap. Reference period: t = \u22121."
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig_event_study.pdf"), p3,
       width = FIG_W, height = FIG_H, device = "pdf")
cat("  Saved: fig_event_study.pdf\n\n")

# ==============================================================================
# FIGURE 4: Bacon decomposition
# ==============================================================================

cat("--- Figure 4: Bacon decomposition ---\n")

if (!is.null(bacon_out)) {
  bacon_df <- as.data.frame(bacon_out)

  # Color by type of comparison
  p4 <- ggplot(bacon_df, aes(x = weight, y = estimate, color = type, shape = type)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60",
               linewidth = 0.4) +
    geom_point(size = 3, alpha = 0.8) +
    scale_color_manual(
      values = c(
        "Earlier vs Later Treated" = apep_colors[1],
        "Later vs Earlier Treated" = apep_colors[2],
        "Treated vs Untreated"     = apep_colors[3]
      )
    ) +
    scale_shape_manual(
      values = c(
        "Earlier vs Later Treated" = 16,
        "Later vs Earlier Treated" = 17,
        "Treated vs Untreated"     = 15
      )
    ) +
    labs(
      title = "Bacon Decomposition of TWFE Estimate",
      subtitle = "2x2 DD estimates vs. decomposition weights",
      x = "Weight",
      y = "2x2 DD Estimate (pp)",
      color = "Comparison Type",
      shape = "Comparison Type"
    ) +
    theme_apep() +
    theme(legend.position = "bottom",
          legend.title = element_text(size = 9))

  ggsave(file.path(FIG_DIR, "fig_bacon.pdf"), p4,
         width = FIG_W, height = FIG_H, device = "pdf")
  cat("  Saved: fig_bacon.pdf\n\n")
} else {
  cat("  Bacon decomposition not available; skipping figure.\n\n")
}

# ==============================================================================
# FIGURE 5: HonestDiD sensitivity
# ==============================================================================

cat("--- Figure 5: HonestDiD sensitivity ---\n")

if (!is.null(honest_results) && !is.null(honest_results$relative_magnitudes)) {
  rm_df <- honest_results$relative_magnitudes

  # Check if the CI crosses zero
  rm_df$excludes_zero <- (rm_df$lb > 0) | (rm_df$ub < 0)

  p5 <- ggplot(rm_df, aes(x = Mbar)) +
    # Zero reference
    geom_hline(yintercept = 0, linetype = "solid", color = "grey50",
               linewidth = 0.4) +
    # CI band
    geom_ribbon(aes(ymin = lb, ymax = ub), fill = apep_colors[1], alpha = 0.15) +
    # CI bounds as lines
    geom_line(aes(y = lb), color = apep_colors[1], linewidth = 0.7, linetype = "dashed") +
    geom_line(aes(y = ub), color = apep_colors[1], linewidth = 0.7, linetype = "dashed") +
    # Midpoint
    geom_line(aes(y = (lb + ub) / 2), color = apep_colors[1], linewidth = 0.9) +
    geom_point(aes(y = (lb + ub) / 2), color = apep_colors[1], size = 2.5) +
    # Original estimate reference
    geom_hline(yintercept = att_overall$overall.att, linetype = "dotted",
               color = apep_colors[2], linewidth = 0.5) +
    annotate("text", x = max(rm_df$Mbar), y = att_overall$overall.att,
             label = paste0("Baseline ATT = ", sprintf("%.3f", att_overall$overall.att)),
             hjust = 1, vjust = -0.5, size = 3, color = apep_colors[2]) +
    labs(
      title = "Sensitivity to Violations of Parallel Trends",
      subtitle = "Rambachan & Roth (2023) relative magnitudes approach",
      x = expression(bar(M) ~ "(Maximum relative deviation from parallel trends)"),
      y = "Robust Confidence Interval for ATT",
      caption = "Notes: Bars show 95% robust CIs. Dashed horizontal line = baseline ATT."
    ) +
    theme_apep()

  ggsave(file.path(FIG_DIR, "fig_honestdid.pdf"), p5,
         width = FIG_W, height = FIG_H, device = "pdf")
  cat("  Saved: fig_honestdid.pdf\n\n")
} else {
  cat("  HonestDiD results not available; skipping figure.\n\n")
}

# ==============================================================================
# FIGURE 6: Heterogeneity by region
# ==============================================================================

cat("--- Figure 6: Heterogeneity ---\n")

if (!is.null(region_results) && length(region_results) > 0) {
  # Build a data frame of region-level ATTs
  het_df <- data.frame(
    region  = character(),
    att     = numeric(),
    se      = numeric(),
    ci_lo   = numeric(),
    ci_hi   = numeric(),
    n_treat = integer(),
    stringsAsFactors = FALSE
  )

  for (reg in names(region_results)) {
    r <- region_results[[reg]]
    het_df <- bind_rows(het_df, data.frame(
      region  = reg,
      att     = r$att_obj$overall.att,
      se      = r$att_obj$overall.se,
      ci_lo   = r$att_obj$overall.att - 1.96 * r$att_obj$overall.se,
      ci_hi   = r$att_obj$overall.att + 1.96 * r$att_obj$overall.se,
      n_treat = r$n_treated,
      stringsAsFactors = FALSE
    ))
  }

  # Add overall ATT for reference
  het_df <- bind_rows(
    het_df,
    data.frame(
      region  = "Overall",
      att     = att_overall$overall.att,
      se      = att_overall$overall.se,
      ci_lo   = att_overall$overall.att - 1.96 * att_overall$overall.se,
      ci_hi   = att_overall$overall.att + 1.96 * att_overall$overall.se,
      n_treat = NA_integer_,
      stringsAsFactors = FALSE
    )
  )

  # Order: overall first, then alphabetical
  het_df$region <- factor(het_df$region,
                          levels = c(sort(setdiff(het_df$region, "Overall")), "Overall"))

  p6 <- ggplot(het_df, aes(x = region, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60",
               linewidth = 0.4) +
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                  width = 0.2, color = apep_colors[1], linewidth = 0.6) +
    geom_point(aes(fill = ifelse(region == "Overall", "Overall", "Region")),
               size = 3.5, shape = 21, color = "white", stroke = 0.8) +
    scale_fill_manual(values = c("Overall" = apep_colors[2],
                                 "Region"  = apep_colors[1]),
                      guide = "none") +
    # Add sample size labels
    geom_text(aes(label = ifelse(!is.na(n_treat),
                                  paste0("n=", n_treat), "")),
              vjust = -1.5, size = 3, color = "grey40") +
    labs(
      title = "Heterogeneity in Treatment Effects by Census Region",
      subtitle = "CS-DiD ATT with 95% confidence intervals",
      x = NULL,
      y = "ATT: Change in Percent Living with Parents (pp)",
      caption = "Notes: n = number of treated states in region. 95% CIs from clustered bootstrap."
    ) +
    coord_flip() +
    theme_apep()

  ggsave(file.path(FIG_DIR, "fig_heterogeneity.pdf"), p6,
         width = FIG_W, height = FIG_H, device = "pdf")
  cat("  Saved: fig_heterogeneity.pdf\n\n")
} else {
  cat("  Region results not available; skipping heterogeneity figure.\n\n")
}

# ==============================================================================
# FIGURE 7 (BONUS): Comparison of estimators event study
# ==============================================================================

cat("--- Figure 7: Estimator comparison event study ---\n")

# Build event study data from multiple estimators
estimator_es <- es_df %>%
  mutate(estimator = "CS-DiD (never-treated)")

# Add not-yet-treated if available
if (!is.null(es_nyt)) {
  nyt_df <- data.frame(
    event_time = es_nyt$egt,
    att        = es_nyt$att.egt,
    se         = es_nyt$se.egt,
    ci_lo      = es_nyt$att.egt - 1.96 * es_nyt$se.egt,
    ci_hi      = es_nyt$att.egt + 1.96 * es_nyt$se.egt,
    estimator  = "CS-DiD (not-yet-treated)"
  )
  estimator_es <- bind_rows(estimator_es, nyt_df)
}

if (nrow(estimator_es) > 0 && length(unique(estimator_es$estimator)) > 1) {
  p7 <- ggplot(estimator_es, aes(x = event_time, y = att,
                                  color = estimator, shape = estimator)) +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey50",
               linewidth = 0.4) +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey60",
               linewidth = 0.4) +
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                  width = 0.15, linewidth = 0.4,
                  position = position_dodge(width = 0.3)) +
    geom_point(size = 2.2, position = position_dodge(width = 0.3)) +
    scale_color_manual(values = c(
      "CS-DiD (never-treated)"    = apep_colors[1],
      "CS-DiD (not-yet-treated)"  = apep_colors[3]
    )) +
    scale_shape_manual(values = c(
      "CS-DiD (never-treated)"    = 16,
      "CS-DiD (not-yet-treated)"  = 17
    )) +
    scale_x_continuous(breaks = seq(min(estimator_es$event_time),
                                    max(estimator_es$event_time), 1)) +
    labs(
      title = "Event Study: Comparison of Control Group Definitions",
      subtitle = "Callaway & Sant'Anna (2021) with different comparison groups",
      x = "Event Time (Years Relative to Treatment)",
      y = "ATT (pp)",
      color = "Estimator", shape = "Estimator"
    ) +
    theme_apep() +
    theme(legend.position = "bottom")

  ggsave(file.path(FIG_DIR, "fig_estimator_comparison.pdf"), p7,
         width = FIG_W, height = FIG_H, device = "pdf")
  cat("  Saved: fig_estimator_comparison.pdf\n\n")
} else {
  cat("  Only one estimator available; skipping comparison figure.\n\n")
}

# ==============================================================================
# Summary
# ==============================================================================

cat("========================================================\n")
cat("  FIGURES GENERATED\n")
cat("========================================================\n\n")

figs_generated <- list.files(FIG_DIR, pattern = "\\.pdf$")
for (f in figs_generated) {
  cat("  ", f, "\n")
}

cat("\n========================================================\n")
cat("  05_figures.R completed successfully.\n")
cat("========================================================\n")
