## ============================================================================
## 09_figures.R — Publication-Quality Figures
## Paper 184: Dutch Nitrogen Crisis & Housing (Sub-national DiD)
## ============================================================================

source("00_packages.R")

cat("=== 09_figures.R: Generating figures ===\n")

dir.create("../figures", recursive = TRUE, showWarnings = FALSE)

## --- Load all results ---
# Load treatment_vars with geometry from gpkg for map figure
treatment_vars <- tryCatch({
  library(sf)
  tv <- st_read("../data/processed/treatment_vars_geo.gpkg", quiet = TRUE)
  tv <- tv %>% rename(muni_code = gemeentecode)
  tv
}, error = function(e) {
  cat("  Could not load gpkg, falling back to RDS (no geometry)\n")
  readRDS("../data/processed/treatment_vars.rds")
})

panel_prices   <- readRDS("../data/processed/panel_prices.rds")
panel_permits  <- readRDS("../data/processed/panel_permits.rds")

# Add derived columns for permits
panel_permits <- panel_permits %>%
  mutate(permits = dwellings_permitted)

es_results     <- tryCatch(readRDS("../data/processed/event_study_results.rds"), error = function(e) NULL)
fs_results     <- tryCatch(readRDS("../data/processed/first_stage_results.rds"), error = function(e) NULL)
main_results   <- tryCatch(readRDS("../data/processed/main_results.rds"), error = function(e) NULL)
scm_results    <- tryCatch(readRDS("../data/processed/nnls_scm_results.rds"), error = function(e) NULL)
asc_results    <- tryCatch(readRDS("../data/processed/augsynth_results.rds"), error = function(e) NULL)
rob_results    <- tryCatch(readRDS("../data/processed/robustness_results.rds"), error = function(e) NULL)
rdd_results    <- tryCatch(readRDS("../data/processed/rdd_results.rds"), error = function(e) NULL)

save_fig <- function(p, name, w = 8, h = 5) {
  ggsave(paste0("../figures/", name, ".pdf"), p, width = w, height = h, device = cairo_pdf)
  ggsave(paste0("../figures/", name, ".png"), p, width = w, height = h, dpi = 300)
  cat(sprintf("  Saved: %s\n", name))
}

## =========================================================================
## FIGURE 1: Map of Natura 2000 Treatment Intensity
## =========================================================================
cat("Figure 1: N2000 treatment intensity map...\n")

if ("geom" %in% names(treatment_vars) || "geometry" %in% names(treatment_vars)) {
  fig1 <- ggplot(treatment_vars) +
    geom_sf(aes(fill = n2000_share), color = "gray70", linewidth = 0.1) +
    scale_fill_viridis_c(
      option = "plasma",
      name = "Natura 2000\nArea Share",
      labels = scales::percent_format(),
      limits = c(0, NA)
    ) +
    labs(
      title = "Treatment Intensity: Natura 2000 Coverage by Municipality",
      subtitle = "Share of municipality area designated as Natura 2000 protected site",
      caption = "Source: EEA Natura 2000 spatial data; CBS municipality boundaries (2019)."
    ) +
    theme_void() +
    theme(
      plot.title = element_text(face = "bold", size = 13),
      plot.subtitle = element_text(size = 10, color = "gray40"),
      legend.position = "right"
    )
  save_fig(fig1, "fig1_n2000_map", w = 9, h = 7)
} else {
  cat("  Skipping map — no geometry column in treatment_vars\n")
  # Create histogram as fallback
  fig1 <- ggplot(treatment_vars, aes(x = n2000_share)) +
    geom_histogram(bins = 40, fill = cols$accent, color = "white", alpha = 0.8) +
    geom_vline(xintercept = median(treatment_vars$n2000_share[treatment_vars$n2000_share > 0]),
               linetype = "dashed", color = cols$treated) +
    scale_x_continuous(labels = scales::percent_format()) +
    labs(
      title = "Distribution of Natura 2000 Treatment Intensity",
      x = "Share of Municipality Area in Natura 2000",
      y = "Number of Municipalities",
      caption = "Dashed line: median among municipalities with positive N2000 coverage."
    )
  save_fig(fig1, "fig1_n2000_map", w = 8, h = 5)
}

## =========================================================================
## FIGURE 2: Event Study — Building Permits (Quarterly)
## =========================================================================
cat("Figure 2: Permit event study...\n")

if (!is.null(es_results) && !is.null(es_results$es_permits)) {
  es_perm <- es_results$es_permits

  fig2 <- iplot(es_perm, main = "", xlab = "Quarters Relative to Nitrogen Ruling (2019Q2)",
                ylab = "Effect on Building Permits\n(N2000 Share × Event Time)")
  # iplot returns base R plot; convert to ggplot via coefplot approach
  es_df <- as.data.frame(coeftable(es_perm))
  es_df$event_time <- as.numeric(gsub(".*::", "", rownames(es_df)))
  names(es_df) <- c("estimate", "se", "tval", "pval", "event_time")
  es_df$ci_lo <- es_df$estimate - 1.96 * es_df$se
  es_df$ci_hi <- es_df$estimate + 1.96 * es_df$se

  fig2 <- ggplot(es_df, aes(x = event_time, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "solid", color = cols$treated, alpha = 0.5) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = cols$ci, alpha = 0.4) +
    geom_line(color = cols$treated, linewidth = 0.8) +
    geom_point(color = cols$treated, size = 2) +
    annotate("text", x = 0, y = max(es_df$ci_hi, na.rm = TRUE) * 0.9,
             label = "Nitrogen\nRuling", color = cols$treated, size = 3, hjust = 0) +
    labs(
      title = "Event Study: Effect of Natura 2000 Proximity on Building Permits",
      subtitle = "Interaction of N2000 share with quarter dummies (ref: Q1 2019)",
      x = "Quarters Relative to Nitrogen Ruling (2019Q2)",
      y = "Estimated Effect on Building Permits",
      caption = "Municipality and quarter fixed effects. Clustered SEs at municipality level. Shaded: 95% CI."
    )
  save_fig(fig2, "fig2_event_study_permits", w = 10, h = 6)
} else {
  cat("  Skipping — event study results not available\n")
}

## =========================================================================
## FIGURE 3: Event Study — Housing Prices (Annual)
## =========================================================================
cat("Figure 3: Price event study...\n")

if (!is.null(es_results) && !is.null(es_results$es_price)) {
  es_pr <- es_results$es_price
  es_df <- as.data.frame(coeftable(es_pr))
  es_df$event_time <- as.numeric(gsub(".*::", "", rownames(es_df)))
  names(es_df) <- c("estimate", "se", "tval", "pval", "event_time")
  es_df$ci_lo <- es_df$estimate - 1.96 * es_df$se
  es_df$ci_hi <- es_df$estimate + 1.96 * es_df$se

  fig3 <- ggplot(es_df, aes(x = event_time, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "solid", color = cols$treated, alpha = 0.5) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = cols$ci, alpha = 0.4) +
    geom_line(color = cols$control, linewidth = 0.8) +
    geom_point(color = cols$control, size = 2.5) +
    annotate("text", x = 0.5, y = max(es_df$ci_hi, na.rm = TRUE) * 0.9,
             label = "Nitrogen\nRuling", color = cols$treated, size = 3, hjust = 0) +
    labs(
      title = "Event Study: Effect of Natura 2000 Proximity on Housing Prices",
      subtitle = "Interaction of N2000 share with year dummies (ref: 2018)",
      x = "Years Relative to Nitrogen Ruling (2019)",
      y = "Estimated Effect on Log(Price)",
      caption = "Municipality and year fixed effects. Clustered SEs at municipality level. Shaded: 95% CI."
    )
  save_fig(fig3, "fig3_event_study_prices", w = 9, h = 6)
} else {
  cat("  Skipping — price event study results not available\n")
}

## =========================================================================
## FIGURE 4: Binscatter — N2000 Share vs Permit Change
## =========================================================================
cat("Figure 4: Binscatter permits...\n")

tryCatch({
  bin_data_perm <- panel_permits %>%
    mutate(period = ifelse(post, "Post-2019", "Pre-2019")) %>%
    group_by(muni_code, period) %>%
    summarize(mean_permits = mean(permits, na.rm = TRUE),
              n2000_share = first(n2000_share), .groups = "drop") %>%
    pivot_wider(names_from = period, values_from = mean_permits) %>%
    mutate(permit_change = `Post-2019` - `Pre-2019`)

  # Create 20 equal-sized bins
  bin_data_perm <- bin_data_perm %>%
    mutate(bin = ntile(n2000_share, 20)) %>%
    group_by(bin) %>%
    summarize(
      mean_share = mean(n2000_share, na.rm = TRUE),
      mean_change = mean(permit_change, na.rm = TRUE),
      se = sd(permit_change, na.rm = TRUE) / sqrt(n()),
      n = n(), .groups = "drop"
    )

  fig4 <- ggplot(bin_data_perm, aes(x = mean_share, y = mean_change)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_smooth(method = "lm", se = TRUE, color = cols$treated, fill = cols$ci, alpha = 0.3) +
    geom_point(aes(size = n), color = cols$treated, alpha = 0.7) +
    scale_x_continuous(labels = scales::percent_format()) +
    scale_size_continuous(guide = "none") +
    labs(
      title = "Dose-Response: Natura 2000 Exposure and Building Permit Decline",
      x = "Municipality Natura 2000 Area Share",
      y = "Change in Mean Quarterly Permits (Post - Pre)",
      caption = "20 equal-sized bins by N2000 share. Line: OLS fit with 95% CI."
    )
  save_fig(fig4, "fig4_binscatter_permits", w = 8, h = 5.5)
}, error = function(e) cat("  Binscatter permits error:", conditionMessage(e), "\n"))

## =========================================================================
## FIGURE 5: Binscatter — N2000 Share vs Price Change
## =========================================================================
cat("Figure 5: Binscatter prices...\n")

tryCatch({
  bin_data_price <- panel_prices %>%
    mutate(period = ifelse(post, "Post-2019", "Pre-2019")) %>%
    group_by(muni_code, period) %>%
    summarize(mean_lp = mean(log_price, na.rm = TRUE),
              n2000_share = first(n2000_share), .groups = "drop") %>%
    pivot_wider(names_from = period, values_from = mean_lp) %>%
    mutate(price_change = `Post-2019` - `Pre-2019`)

  bin_data_price <- bin_data_price %>%
    mutate(bin = ntile(n2000_share, 20)) %>%
    group_by(bin) %>%
    summarize(
      mean_share = mean(n2000_share, na.rm = TRUE),
      mean_change = mean(price_change, na.rm = TRUE),
      se = sd(price_change, na.rm = TRUE) / sqrt(n()),
      n = n(), .groups = "drop"
    )

  fig5 <- ggplot(bin_data_price, aes(x = mean_share, y = mean_change)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_smooth(method = "lm", se = TRUE, color = cols$control, fill = cols$ci, alpha = 0.3) +
    geom_point(aes(size = n), color = cols$control, alpha = 0.7) +
    scale_x_continuous(labels = scales::percent_format()) +
    scale_size_continuous(guide = "none") +
    labs(
      title = "Dose-Response: Natura 2000 Exposure and Housing Price Growth",
      x = "Municipality Natura 2000 Area Share",
      y = "Change in Log(Price) (Post - Pre)",
      caption = "20 equal-sized bins by N2000 share. Line: OLS fit with 95% CI."
    )
  save_fig(fig5, "fig5_binscatter_prices", w = 8, h = 5.5)
}, error = function(e) cat("  Binscatter prices error:", conditionMessage(e), "\n"))

## =========================================================================
## FIGURE 6: Augmented SCM (National-Level Complement)
## =========================================================================
cat("Figure 6: Augmented SCM...\n")

if (!is.null(asc_results)) {
  tryCatch({
    fig6 <- plot(asc_results$asc) +
      labs(
        title = "Augmented Synthetic Control: Netherlands vs. Synthetic Netherlands",
        subtitle = "National-level complement to sub-national DiD",
        caption = "Ridge-augmented SCM (Ben-Michael et al. 2021). 15 European donor countries."
      )
    save_fig(fig6, "fig6_augmented_scm", w = 9, h = 6)
  }, error = function(e) cat("  augsynth plot error:", conditionMessage(e), "\n"))
} else if (!is.null(scm_results)) {
  # Fallback: plot NNLS SCM
  scm_df <- data.frame(
    date = scm_results$dates,
    Netherlands = scm_results$y_treated,
    Synthetic = scm_results$y_synth
  ) %>% pivot_longer(-date, names_to = "series", values_to = "hpi")

  fig6 <- ggplot(scm_df, aes(x = date, y = hpi, color = series, linetype = series)) +
    geom_vline(xintercept = as.Date("2019-04-01"), linetype = "dashed", color = "gray50") +
    geom_line(linewidth = 1) +
    scale_color_manual(values = c("Netherlands" = cols$treated, "Synthetic" = cols$control)) +
    scale_linetype_manual(values = c("Netherlands" = "solid", "Synthetic" = "dashed")) +
    labs(
      title = "Synthetic Control: Netherlands vs. Synthetic Netherlands",
      subtitle = sprintf("National-level complement (NNLS). Pre-treatment R² = %.3f", scm_results$pre_r2),
      x = "", y = "Real House Price Index (2010Q1 = 100)",
      color = "", linetype = "",
      caption = "Vertical line: nitrogen ruling (May 2019). 15 European donor countries."
    )
  save_fig(fig6, "fig6_augmented_scm", w = 9, h = 6)
} else {
  cat("  Skipping — no SCM results available\n")
}

## =========================================================================
## FIGURE 7: Treatment Effect Gap (SCM)
## =========================================================================
cat("Figure 7: SCM treatment gap...\n")

if (!is.null(scm_results)) {
  gap_df <- data.frame(
    date = scm_results$dates,
    gap = scm_results$gaps,
    post = scm_results$post_mask
  )

  fig7 <- ggplot(gap_df, aes(x = date, y = gap)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = as.Date("2019-04-01"), linetype = "dashed", color = "gray50") +
    geom_area(data = filter(gap_df, post), fill = cols$ci, alpha = 0.3) +
    geom_line(color = cols$treated, linewidth = 0.8) +
    annotate("text", x = as.Date("2021-01-01"), y = max(gap_df$gap) * 0.8,
             label = sprintf("ATT = %.2f", scm_results$att), color = cols$treated, size = 4) +
    labs(
      title = "Treatment Effect: Netherlands minus Synthetic Control",
      x = "", y = "Gap (Index Points)",
      caption = sprintf("ATT = %.2f. Pre-treatment RMSE = %.2f. National-level complement analysis.",
                        scm_results$att, scm_results$pre_rmse)
    )
  save_fig(fig7, "fig7_scm_gap", w = 9, h = 5.5)
}

## =========================================================================
## FIGURE 8: Spatial RDD (if feasible)
## =========================================================================
cat("Figure 8: Spatial RDD...\n")

if (!is.null(rdd_results) && is.null(rdd_results$error)) {
  tryCatch({
    rdd_df <- rdd_results$rdd_data

    fig8 <- ggplot(rdd_df, aes(x = signed_dist, y = mean_price_change)) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
      geom_point(alpha = 0.3, color = "gray40", size = 1) +
      geom_smooth(data = filter(rdd_df, signed_dist < 0), method = "loess", span = 0.5,
                  color = cols$treated, fill = cols$treated, alpha = 0.2) +
      geom_smooth(data = filter(rdd_df, signed_dist >= 0), method = "loess", span = 0.5,
                  color = cols$control, fill = cols$control, alpha = 0.2) +
      labs(
        title = "Spatial RDD: Price Changes at Natura 2000 Boundary",
        x = "Signed Distance to Nearest Natura 2000 Site (km)\n(Negative = Inside/Overlapping)",
        y = "Mean Log Price Change (Post - Pre-2019)",
        caption = "Each point is a municipality. Local polynomial smoothing on each side."
      )
    save_fig(fig8, "fig8_spatial_rdd", w = 8, h = 5.5)
  }, error = function(e) cat("  RDD plot error:", conditionMessage(e), "\n"))
} else {
  cat("  Skipping — spatial RDD not feasible or results unavailable\n")
}

## =========================================================================
## FIGURE 9: Mean Prices by Treatment Group Over Time
## =========================================================================
cat("Figure 9: Prices by treatment group...\n")

tryCatch({
  group_means <- panel_prices %>%
    mutate(group = case_when(
      n2000_tertile == 3 ~ "High N2000 Exposure",
      n2000_tertile == 2 ~ "Medium N2000 Exposure",
      n2000_tertile == 1 ~ "Low N2000 Exposure"
    )) %>%
    group_by(year, group) %>%
    summarize(
      mean_price = mean(price, na.rm = TRUE),
      se = sd(price, na.rm = TRUE) / sqrt(n()),
      .groups = "drop"
    )

  fig9 <- ggplot(group_means, aes(x = year, y = mean_price / 1000, color = group)) +
    geom_vline(xintercept = 2019, linetype = "dashed", color = "gray50") +
    geom_line(linewidth = 0.9) +
    geom_point(size = 2) +
    scale_color_manual(values = c(
      "High N2000 Exposure" = cols$treated,
      "Medium N2000 Exposure" = cols$medium,
      "Low N2000 Exposure" = cols$control
    )) +
    labs(
      title = "Average Housing Prices by Natura 2000 Exposure Tertile",
      x = "Year", y = "Average Purchase Price (thousands EUR)",
      color = "",
      caption = "Municipalities grouped by N2000 area share tertile. Vertical line: nitrogen ruling (2019)."
    )
  save_fig(fig9, "fig9_prices_by_group", w = 9, h = 5.5)
}, error = function(e) cat("  Group means plot error:", conditionMessage(e), "\n"))

## =========================================================================
## FIGURE 10: Pre-COVID vs Full-Sample Comparison
## =========================================================================
cat("Figure 10: Pre-COVID vs full sample...\n")

if (!is.null(rob_results)) {
  tryCatch({
    compare_df <- data.frame(
      Sample = c("Pre-COVID\n(2012-2019)", "Full Sample\n(2012-2024)"),
      ATT = c(coef(rob_results$rob_precovid)[1], coef(rob_results$rob_full)[1]),
      SE = c(se(rob_results$rob_precovid)[1], se(rob_results$rob_full)[1])
    ) %>% mutate(
      ci_lo = ATT - 1.96 * SE,
      ci_hi = ATT + 1.96 * SE
    )

    fig10 <- ggplot(compare_df, aes(x = Sample, y = ATT)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi), color = cols$control, size = 1, linewidth = 1) +
      labs(
        title = "Robustness: Pre-COVID vs Full-Sample Estimates",
        subtitle = "Effect of N2000 proximity on log housing prices",
        x = "", y = "Estimated Effect (N2000 Share × Post)",
        caption = "Municipality and year FE. Clustered SEs at municipality level. Bars: 95% CI."
      )
    save_fig(fig10, "fig10_precovid_comparison", w = 6, h = 5)
  }, error = function(e) cat("  Pre-COVID comparison error:", conditionMessage(e), "\n"))
} else {
  cat("  Skipping — robustness results not available\n")
}

cat("\n=== All figures generated ===\n")
cat("Files in figures/:\n")
print(list.files("../figures"))
