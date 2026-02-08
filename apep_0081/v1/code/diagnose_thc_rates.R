# =============================================================================
# Diagnose THC Rate Discrepancy: Figure 2 vs Table 2 Panel C
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load the exact data used for figures
fars <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed_clean.rds"))

THC_YEARS <- c(2018, 2019)

message("\n=== DIAGNOSE THC RATE DISCREPANCY ===\n")

# --------------------------------------------------------------------------
# Method 1: How Figure 3 computes it (by year, ever_rec_legal grouping)
# --------------------------------------------------------------------------
message("FIGURE 3 Method (by year):")
fig_rates <- fars %>%
  filter(year %in% THC_YEARS, !is.na(thc_positive)) %>%
  group_by(year, ever_rec_legal) %>%
  summarise(
    n_with_record = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / n_with_record,
    .groups = "drop"
  )
print(fig_rates)

# --------------------------------------------------------------------------
# Method 2: Pooled 2018-2019 (for Table 2 Panel C)
# --------------------------------------------------------------------------
message("\nTABLE 2 PANEL C Method (pooled 2018-2019):")
table_rates <- fars %>%
  filter(year %in% THC_YEARS, !is.na(thc_positive)) %>%
  group_by(ever_rec_legal) %>%
  summarise(
    n_with_record = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / n_with_record,
    .groups = "drop"
  )
print(table_rates)

# --------------------------------------------------------------------------
# Verify pooled rate is weighted average of year rates
# --------------------------------------------------------------------------
message("\nVerify pooled = weighted average of year rates:")
legal_2018 <- filter(fig_rates, year == 2018, ever_rec_legal == TRUE)
legal_2019 <- filter(fig_rates, year == 2019, ever_rec_legal == TRUE)
legal_pooled <- filter(table_rates, ever_rec_legal == TRUE)

weighted_avg <- (legal_2018$thc_pos + legal_2019$thc_pos) /
                (legal_2018$n_with_record + legal_2019$n_with_record) * 100

message("  2018 Legal rate: ", round(legal_2018$pct_thc, 1), "% (n=", legal_2018$n_with_record, ")")
message("  2019 Legal rate: ", round(legal_2019$pct_thc, 1), "% (n=", legal_2019$n_with_record, ")")
message("  Computed pooled (weighted): ", round(weighted_avg, 1), "%")
message("  Actual pooled from table method: ", round(legal_pooled$pct_thc, 1), "% (n=", legal_pooled$n_with_record, ")")

# Check if there's a discrepancy
if (abs(weighted_avg - legal_pooled$pct_thc) > 0.1) {
  message("\n  WARNING: Discrepancy detected!")
} else {
  message("\n  OK: Values match.")
}

# --------------------------------------------------------------------------
# Print summary for paper correction
# --------------------------------------------------------------------------
message("\n=== VALUES TO USE IN PAPER ===")
message("Table 2 Panel C should show:")
message("  Legal (2018-2019 pooled): ", round(legal_pooled$pct_thc, 1), "%")
comparison_pooled <- filter(table_rates, ever_rec_legal == FALSE)
message("  Comparison (2018-2019 pooled): ", round(comparison_pooled$pct_thc, 1), "%")

message("\nFigure 3 year values:")
message("  Legal 2018: ", round(legal_2018$pct_thc, 1), "%")
message("  Legal 2019: ", round(legal_2019$pct_thc, 1), "%")

# Check also the comparison states
comp_2018 <- filter(fig_rates, year == 2018, ever_rec_legal == FALSE)
comp_2019 <- filter(fig_rates, year == 2019, ever_rec_legal == FALSE)
message("  Comparison 2018: ", round(comp_2018$pct_thc, 1), "%")
message("  Comparison 2019: ", round(comp_2019$pct_thc, 1), "%")

message("\n=== DIAGNOSIS COMPLETE ===")
