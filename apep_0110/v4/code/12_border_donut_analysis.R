# =============================================================================
# 12_border_donut_analysis.R
# Border-by-Border Donut RDD Analysis
# Investigates which border(s) drive the 2km donut anomaly
# =============================================================================

source("00_packages.R")

# Load data
crashes <- readRDS("../data/crashes_analysis.rds")
crashes$rv <- -crashes$running_var  # Positive = legal

cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("BORDER-BY-BORDER DONUT RDD ANALYSIS\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

# =============================================================================
# PART 1: Define Border Regions
# =============================================================================

cat("Defining border regions...\n\n")

# Create more granular border assignments
crashes <- crashes %>%
  mutate(
    border_region = case_when(
      # Colorado borders (individual)
      NAME %in% c("Colorado", "Wyoming") ~ "CO-WY",
      NAME %in% c("Colorado", "Nebraska") &
        NAME == "Nebraska" ~ "CO-NE",
      NAME %in% c("Colorado", "Kansas") &
        NAME == "Kansas" ~ "CO-KS",
      NAME %in% c("Colorado", "New Mexico") &
        NAME == "New Mexico" ~ "CO-NM",
      NAME %in% c("Colorado", "Utah") &
        NAME == "Utah" ~ "CO-UT",
      NAME == "Colorado" ~ "CO (all)",

      # Nevada borders
      NAME %in% c("Nevada", "Utah") &
        NAME == "Utah" ~ "NV-UT",
      NAME %in% c("Nevada", "Arizona") &
        NAME == "Arizona" ~ "NV-AZ",
      NAME == "Nevada" ~ "NV (all)",

      # California-Arizona
      NAME %in% c("California", "Arizona") ~ "CA-AZ",
      NAME == "California" ~ "CA (all)",

      # Oregon/Washington-Idaho
      NAME %in% c("Oregon", "Idaho") ~ "OR-ID",
      NAME %in% c("Washington", "Idaho") ~ "WA-ID",
      NAME == "Oregon" ~ "OR (all)",
      NAME == "Washington" ~ "WA (all)",

      TRUE ~ "Other"
    )
  )

# For analysis, group crashes by their relevant legal-prohibition border pair
# Reassign to get paired regions
crashes <- crashes %>%
  mutate(
    border_pair = case_when(
      NAME %in% c("Colorado", "Wyoming") ~ "CO-WY",
      NAME %in% c("Colorado", "Nebraska") ~ "CO-NE",
      NAME %in% c("Colorado", "Kansas") ~ "CO-KS",
      NAME %in% c("Colorado", "New Mexico") ~ "CO-NM",
      NAME %in% c("Colorado", "Utah") ~ "CO/NV-UT",
      NAME %in% c("Nevada", "Utah") ~ "CO/NV-UT",
      NAME %in% c("Nevada", "Arizona") ~ "NV/CA-AZ",
      NAME %in% c("California", "Arizona") ~ "NV/CA-AZ",
      NAME %in% c("Oregon", "Idaho") ~ "OR/WA-ID",
      NAME %in% c("Washington", "Idaho") ~ "OR/WA-ID",
      TRUE ~ "Other"
    )
  )

cat("Border pair distribution:\n")
border_counts <- crashes %>%
  group_by(border_pair) %>%
  summarise(
    n = n(),
    n_legal = sum(legal_status == "Legal"),
    n_prohib = sum(legal_status == "Prohibition"),
    .groups = "drop"
  ) %>%
  filter(border_pair != "Other")
print(border_counts)

# =============================================================================
# PART 2: Run Donut RDD for Each Border Pair
# =============================================================================

cat("\n\nRunning border-specific donut RDD...\n")
cat(paste0(rep("-", 50), collapse = ""), "\n\n")

donut_sizes <- c(0, 2, 5, 10)  # km
border_pairs <- c("CO-WY", "CO-NE", "CO-KS", "CO-NM", "CO/NV-UT", "NV/CA-AZ", "OR/WA-ID")

# Store all results
all_donut_results <- data.frame()

for (bp in border_pairs) {
  data_bp <- crashes %>% filter(border_pair == bp)

  n_legal <- sum(data_bp$legal_status == "Legal")
  n_prohib <- sum(data_bp$legal_status == "Prohibition")

  cat(sprintf("\n%s: N_legal=%d, N_prohib=%d\n", bp, n_legal, n_prohib))

  if (n_legal < 50 | n_prohib < 50) {
    cat(sprintf("  Skipping (insufficient observations)\n"))
    next
  }

  for (donut in donut_sizes) {
    # Apply donut: exclude crashes within donut km of border
    data_donut <- data_bp %>% filter(abs(rv) > donut)

    if (nrow(data_donut) < 100) {
      cat(sprintf("  Donut %d km: insufficient data\n", donut))
      next
    }

    rdd_result <- tryCatch({
      rdrobust(
        y = data_donut$alcohol_involved,
        x = data_donut$rv,
        c = 0,
        kernel = "triangular",
        p = 1,
        bwselect = "mserd"
      )
    }, error = function(e) {
      cat(sprintf("  Donut %d km: RDD failed (%s)\n", donut, e$message))
      NULL
    })

    if (!is.null(rdd_result)) {
      all_donut_results <- rbind(all_donut_results, data.frame(
        border_pair = bp,
        donut_km = donut,
        n_total = nrow(data_donut),
        n_effective = rdd_result$N_h[1] + rdd_result$N_h[2],
        estimate = rdd_result$coef[1],
        se = rdd_result$se[1],
        ci_lower = rdd_result$coef[1] - 1.96 * rdd_result$se[1],
        ci_upper = rdd_result$coef[1] + 1.96 * rdd_result$se[1],
        bandwidth = rdd_result$bws[1, 1],
        p_value = 2 * pnorm(-abs(rdd_result$coef[1] / rdd_result$se[1])),
        significant = abs(rdd_result$coef[1]) > 1.96 * rdd_result$se[1]
      ))

      sig_marker <- ifelse(abs(rdd_result$coef[1]) > 1.96 * rdd_result$se[1], "*", "")
      cat(sprintf("  Donut %d km: tau = %.3f (SE = %.3f)%s, N_eff = %d\n",
                  donut, rdd_result$coef[1], rdd_result$se[1], sig_marker,
                  rdd_result$N_h[1] + rdd_result$N_h[2]))
    }
  }
}

# =============================================================================
# PART 3: Focus on 2km Donut Analysis
# =============================================================================

cat("\n\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("2KM DONUT DECOMPOSITION\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

donut_2km <- all_donut_results %>% filter(donut_km == 2)

if (nrow(donut_2km) > 0) {
  cat("Border-specific 2km donut estimates:\n\n")

  donut_2km_sorted <- donut_2km %>%
    arrange(desc(estimate)) %>%
    mutate(
      sig_stars = case_when(
        p_value < 0.01 ~ "***",
        p_value < 0.05 ~ "**",
        p_value < 0.10 ~ "*",
        TRUE ~ ""
      )
    )

  for (i in 1:nrow(donut_2km_sorted)) {
    row <- donut_2km_sorted[i, ]
    cat(sprintf("  %s: %.3f (SE = %.3f) %s [N_eff = %d]\n",
                row$border_pair, row$estimate, row$se, row$sig_stars, row$n_effective))
  }

  # Identify which borders drive the significant pooled result
  cat("\n\nAnalysis:\n")
  sig_positive <- donut_2km %>% filter(significant & estimate > 0)
  if (nrow(sig_positive) > 0) {
    cat(sprintf("Significant positive 2km donut results found at: %s\n",
                paste(sig_positive$border_pair, collapse = ", ")))
  } else {
    cat("No individual border shows a significant positive 2km donut result.\n")
    cat("The pooled significance may arise from aggregation across borders.\n")
  }
}

# =============================================================================
# PART 4: Create Comparison Table (Donut 0 vs 2 km)
# =============================================================================

cat("\n\nDONUT 0 vs 2 KM COMPARISON\n")
cat(paste0(rep("-", 50), collapse = ""), "\n\n")

comparison <- all_donut_results %>%
  filter(donut_km %in% c(0, 2)) %>%
  select(border_pair, donut_km, estimate, se, significant) %>%
  pivot_wider(
    names_from = donut_km,
    values_from = c(estimate, se, significant),
    names_glue = "{.value}_{donut_km}km"
  ) %>%
  mutate(
    change = estimate_2km - estimate_0km,
    change_direction = case_when(
      change > 0.1 ~ "Large increase",
      change > 0.05 ~ "Moderate increase",
      change < -0.1 ~ "Large decrease",
      change < -0.05 ~ "Moderate decrease",
      TRUE ~ "Stable"
    )
  )

print(comparison)

# =============================================================================
# PART 5: Forest Plot of 2km Donut by Border
# =============================================================================

cat("\n\nCreating 2km donut forest plot by border...\n")

# Filter to borders that have complete donut analysis (exclude CO/NV-UT which fails at 5km+)
# Keep only: CO-WY, NV/CA-AZ, OR/WA-ID (matching Table 10 in paper)
donut_2km_for_plot <- donut_2km %>%
  filter(border_pair %in% c("CO-WY", "NV/CA-AZ", "OR/WA-ID"))

if (nrow(donut_2km_for_plot) >= 1) {
  # Calculate pooled 2km estimate via inverse-variance weighting
  if (nrow(donut_2km_for_plot) > 1) {
    weights <- 1 / (donut_2km_for_plot$se^2)
    pooled_est <- sum(donut_2km_for_plot$estimate * weights) / sum(weights)
    pooled_se <- sqrt(1 / sum(weights))

    plot_data <- donut_2km_for_plot %>%
      select(border_pair, estimate, ci_lower, ci_upper, n_effective) %>%
      mutate(type = "Individual") %>%
      bind_rows(
        data.frame(
          border_pair = "Pooled (2km donut)",
          estimate = pooled_est,
          ci_lower = pooled_est - 1.96 * pooled_se,
          ci_upper = pooled_est + 1.96 * pooled_se,
          n_effective = sum(donut_2km_for_plot$n_effective),
          type = "Pooled"
        )
      )
  } else {
    plot_data <- donut_2km_for_plot %>%
      select(border_pair, estimate, ci_lower, ci_upper, n_effective) %>%
      mutate(type = "Individual")
    pooled_est <- donut_2km_for_plot$estimate[1]
    pooled_se <- donut_2km$se[1]
  }

  # Order by estimate
  plot_data <- plot_data %>%
    mutate(
      border_pair = factor(border_pair,
                           levels = c(if (nrow(donut_2km) > 1) "Pooled (2km donut)" else NULL,
                                     rev(donut_2km$border_pair[order(donut_2km$estimate)])))
    )

  p_forest <- ggplot(plot_data, aes(x = estimate, y = border_pair)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2) +
    geom_point(aes(size = n_effective, color = type), shape = 15) +
    scale_color_manual(values = c("Individual" = "steelblue", "Pooled" = "darkred"),
                      guide = "none") +
    scale_size_continuous(range = c(2, 5), guide = "none") +
    labs(
      x = "RDD Estimate (Alcohol Involvement Difference)",
      y = "",
      title = "2km Donut RDD by Border Segment",
      subtitle = "Decomposing the 2km donut anomaly",
      caption = "Note: Squares sized by effective sample. Dashed line = null effect."
    ) +
    theme_minimal(base_size = 11) +
    theme(
      panel.grid.major.y = element_blank(),
      plot.title = element_text(face = "bold"),
      axis.text.y = element_text(hjust = 0)
    )

  ggsave("../figures/fig09_border_donut_forest.pdf", p_forest, width = 8, height = 5)
  cat("Saved: fig09_border_donut_forest.pdf\n")
}

# =============================================================================
# PART 6: Save Results
# =============================================================================

saveRDS(all_donut_results, "../data/border_donut_results.rds")
saveRDS(donut_2km, "../data/donut_2km_by_border.rds")
if (exists("comparison")) {
  saveRDS(comparison, "../data/donut_comparison.rds")
}

# =============================================================================
# Summary Table for Paper
# =============================================================================

cat("\n\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("TABLE FOR PAPER: BORDER-SPECIFIC DONUT RDD\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

# Wide format table: rows = borders, columns = donut sizes
table_for_paper <- all_donut_results %>%
  mutate(
    cell = sprintf("%.3f (%.3f)", estimate, se),
    sig = ifelse(significant, "*", "")
  ) %>%
  select(border_pair, donut_km, cell, sig, n_effective) %>%
  mutate(cell_with_sig = paste0(cell, sig)) %>%
  select(border_pair, donut_km, cell_with_sig, n_effective) %>%
  pivot_wider(
    names_from = donut_km,
    values_from = c(cell_with_sig, n_effective),
    names_glue = "donut_{donut_km}km_{.value}"
  )

print(table_for_paper)

cat("\n\nBORDER-BY-BORDER DONUT ANALYSIS COMPLETE\n")
