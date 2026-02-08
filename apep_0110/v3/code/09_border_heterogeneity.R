# =============================================================================
# 09_border_heterogeneity.R
# Border-by-Border RDD with Meta-Analysis
# Addresses reviewer concern: pooling across heterogeneous borders
# =============================================================================

source("00_packages.R")

# Load data
crashes <- readRDS("../data/crashes_analysis.rds")
crashes$rv <- -crashes$running_var  # Positive = legal

cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("BORDER-BY-BORDER RDD ANALYSIS\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

# =============================================================================
# PART 1: Assign Border Segments Based on State
# =============================================================================

cat("Assigning crashes to border segments based on state...\n\n")

# Map states to their primary border segment
# Legal states go to their aggregate borders
# Prohibition states map to their nearest legal neighbor
crashes <- crashes %>%
  mutate(
    border_segment = case_when(
      NAME == "Colorado" ~ "CO borders",
      NAME == "California" ~ "CA borders",
      NAME == "Oregon" ~ "OR-ID/WA",
      NAME == "Washington" ~ "WA-ID",
      NAME == "Nevada" ~ "NV borders",
      NAME == "Wyoming" ~ "CO-WY",
      NAME == "Utah" ~ "CO/NV-UT",
      NAME == "Kansas" ~ "CO-KS",
      NAME == "Nebraska" ~ "CO-NE",
      NAME == "New Mexico" ~ "CO-NM",
      NAME == "Idaho" ~ "OR/WA-ID",
      NAME == "Arizona" ~ "NV/CA-AZ",
      NAME == "Montana" ~ "Other",
      TRUE ~ "Other"
    )
  )

cat("Border segment distribution:\n")
print(table(crashes$border_segment))

# =============================================================================
# PART 2: Run RDD for Each Border Region
# =============================================================================

cat("\n\nRunning region-specific RDD estimates...\n")
cat(paste0(rep("-", 50), collapse = ""), "\n\n")

# Get segments with sufficient sample (need obs on both sides)
segments_to_analyze <- c("CO borders", "NV borders", "CA borders", "OR-ID/WA", "WA-ID")

border_results <- data.frame()

for (seg in segments_to_analyze) {
  # For legal state segments, we need crashes near the border on both sides
  # Use the pooled approach but filtered by region

  if (seg == "CO borders") {
    # Colorado and its prohibition neighbors
    data_seg <- crashes %>%
      filter(NAME %in% c("Colorado", "Wyoming", "Utah", "Kansas", "Nebraska", "New Mexico"))
  } else if (seg == "NV borders") {
    # Nevada and its prohibition neighbors
    data_seg <- crashes %>%
      filter(NAME %in% c("Nevada", "Utah", "Arizona"))
  } else if (seg == "CA borders") {
    # California and Arizona
    data_seg <- crashes %>%
      filter(NAME %in% c("California", "Arizona"))
  } else if (seg == "OR-ID/WA") {
    # Oregon/Washington and Idaho
    data_seg <- crashes %>%
      filter(NAME %in% c("Oregon", "Washington", "Idaho"))
  } else if (seg == "WA-ID") {
    # Washington and Idaho only
    data_seg <- crashes %>%
      filter(NAME %in% c("Washington", "Idaho"))
  } else {
    next
  }

  n_legal <- sum(data_seg$legal_status == "Legal")
  n_prohib <- sum(data_seg$legal_status == "Prohibition")

  cat(sprintf("%s: N_legal=%d, N_prohib=%d\n", seg, n_legal, n_prohib))

  if (n_legal < 100 | n_prohib < 100) {
    cat(sprintf("  Skipping (insufficient observations)\n"))
    next
  }

  rdd_seg <- tryCatch({
    rdrobust(
      y = data_seg$alcohol_involved,
      x = data_seg$rv,
      c = 0,
      kernel = "triangular",
      p = 1,
      bwselect = "mserd"
    )
  }, error = function(e) {
    cat(sprintf("  RDD failed: %s\n", e$message))
    NULL
  })

  if (!is.null(rdd_seg)) {
    border_results <- rbind(border_results, data.frame(
      border_segment = seg,
      n_total = nrow(data_seg),
      n_legal = n_legal,
      n_prohib = n_prohib,
      n_effective = rdd_seg$N_h[1] + rdd_seg$N_h[2],
      estimate = rdd_seg$coef[1],
      se = rdd_seg$se[1],
      ci_lower = rdd_seg$coef[1] - 1.96 * rdd_seg$se[1],
      ci_upper = rdd_seg$coef[1] + 1.96 * rdd_seg$se[1],
      bandwidth = rdd_seg$bws[1, 1],
      p_value = 2 * pnorm(-abs(rdd_seg$coef[1] / rdd_seg$se[1]))
    ))

    cat(sprintf("  tau = %.3f (SE = %.3f), p = %.3f, N_eff = %d, BW = %.1f km\n",
                rdd_seg$coef[1], rdd_seg$se[1],
                2 * pnorm(-abs(rdd_seg$coef[1] / rdd_seg$se[1])),
                rdd_seg$N_h[1] + rdd_seg$N_h[2], rdd_seg$bws[1, 1]))
  }
}

# =============================================================================
# PART 3: Meta-Analysis (Inverse-Variance Weighted Average)
# =============================================================================

cat("\n\nMETA-ANALYSIS\n")
cat(paste0(rep("-", 50), collapse = ""), "\n\n")

if (nrow(border_results) > 1) {
  # Inverse variance weights
  border_results$weight <- 1 / (border_results$se^2)

  # Weighted average
  meta_estimate <- sum(border_results$estimate * border_results$weight) /
                   sum(border_results$weight)
  meta_se <- sqrt(1 / sum(border_results$weight))

  # Q-statistic for heterogeneity
  Q <- sum(border_results$weight * (border_results$estimate - meta_estimate)^2)
  df <- nrow(border_results) - 1
  p_het <- 1 - pchisq(Q, df)

  # I-squared
  I2 <- max(0, (Q - df) / Q * 100)

  cat(sprintf("Meta-analysis pooled estimate: %.4f (SE = %.4f)\n", meta_estimate, meta_se))
  cat(sprintf("95%% CI: [%.4f, %.4f]\n", meta_estimate - 1.96*meta_se, meta_estimate + 1.96*meta_se))
  cat(sprintf("\nHeterogeneity:\n"))
  cat(sprintf("  Q-statistic: %.2f (df = %d, p = %.3f)\n", Q, df, p_het))
  cat(sprintf("  I-squared: %.1f%%\n", I2))

  # Store meta results
  meta_results <- list(
    estimate = meta_estimate,
    se = meta_se,
    ci_lower = meta_estimate - 1.96 * meta_se,
    ci_upper = meta_estimate + 1.96 * meta_se,
    Q = Q,
    df = df,
    p_heterogeneity = p_het,
    I2 = I2
  )

  saveRDS(meta_results, "../data/meta_analysis.rds")
} else {
  meta_estimate <- border_results$estimate[1]
  meta_se <- border_results$se[1]
  cat("Only one border segment available; no meta-analysis computed.\n")
}

# Save border-specific results
saveRDS(border_results, "../data/border_rdd_results.rds")

# =============================================================================
# PART 4: Forest Plot
# =============================================================================

cat("\n\nCreating forest plot...\n")

if (nrow(border_results) >= 1) {
  # Add pooled estimate to results for plotting
  plot_data <- border_results %>%
    select(border_segment, estimate, ci_lower, ci_upper, n_effective) %>%
    mutate(type = "Individual")

  if (nrow(border_results) > 1) {
    plot_data <- plot_data %>%
      bind_rows(
        data.frame(
          border_segment = "Pooled (meta)",
          estimate = meta_estimate,
          ci_lower = meta_estimate - 1.96 * meta_se,
          ci_upper = meta_estimate + 1.96 * meta_se,
          n_effective = sum(border_results$n_effective),
          type = "Pooled"
        )
      )
  }

  # Order by estimate
  plot_data <- plot_data %>%
    mutate(
      border_segment = factor(border_segment,
                              levels = c(if (nrow(border_results) > 1) "Pooled (meta)" else NULL,
                                        rev(border_results$border_segment[order(border_results$estimate)])))
    )

  # Create forest plot
  p_forest <- ggplot(plot_data, aes(x = estimate, y = border_segment)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2) +
    geom_point(aes(size = n_effective, color = type), shape = 15) +
    scale_color_manual(values = c("Individual" = "steelblue", "Pooled" = "darkred"),
                      guide = "none") +
    scale_size_continuous(range = c(2, 5), guide = "none") +
    labs(
      x = "RDD Estimate (Alcohol Involvement Difference)",
      y = "",
      title = "Border-Specific RDD Estimates",
      subtitle = "Effect of legal cannabis access on alcohol involvement in fatal crashes",
      caption = "Note: Squares sized by effective sample size. Dashed line at null effect."
    ) +
    theme_minimal(base_size = 11) +
    theme(
      panel.grid.major.y = element_blank(),
      plot.title = element_text(face = "bold"),
      axis.text.y = element_text(hjust = 0)
    )

  ggsave("../figures/fig06_forest_plot.pdf", p_forest, width = 8, height = 5)
  cat("Saved: fig06_forest_plot.pdf\n")
}

# =============================================================================
# Summary
# =============================================================================

cat("\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("BORDER HETEROGENEITY ANALYSIS COMPLETE\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

cat("Results summary:\n")
print(border_results %>% select(border_segment, estimate, se, p_value, n_effective))

if (exists("meta_results")) {
  cat(sprintf("\nPooled meta-analysis: %.3f (%.3f)\n", meta_results$estimate, meta_results$se))
  if (meta_results$p_heterogeneity < 0.05) {
    cat("WARNING: Significant heterogeneity across borders (p < 0.05)\n")
  } else {
    cat("No significant heterogeneity detected (p >= 0.05)\n")
  }
}
