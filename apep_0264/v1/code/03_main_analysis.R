## 03_main_analysis.R — Primary CS-DiD estimation
## Paper: "The Quiet Life Goes Macro" (apep_0243)

source("00_packages.R")

cat("=== MAIN ANALYSIS ===\n")

panel <- readRDS("../data/analysis_panel.rds")

# ============================================================
# A) TREATMENT ROLLOUT DIAGNOSTICS
# ============================================================

cat("--- Treatment rollout ---\n")

cohort_sizes <- panel %>%
  filter(first_treat > 0) %>%
  distinct(state_fips, first_treat) %>%
  count(first_treat, name = "n_states")

cat("Cohort sizes:\n")
print(cohort_sizes)

# ============================================================
# B) CALLAWAY-SANT'ANNA: Average Establishment Size
# ============================================================

cat("\n--- CS-DiD: Average Establishment Size ---\n")

# Restrict to years with good coverage
panel_cs <- panel %>%
  filter(year >= 1988, year <= 2019) %>%
  filter(!is.na(avg_estab_size)) %>%
  # Log transform for interpretability
  mutate(log_avg_size = log(avg_estab_size))

cs_size <- att_gt(
  yname = "log_avg_size",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = panel_cs,
  control_group = "nevertreated",
  base_period = "universal",
  print_details = FALSE
)

# Aggregate: overall ATT
att_size <- aggte(cs_size, type = "simple")
cat(sprintf("ATT (log avg estab size): %.4f (SE: %.4f, p=%.3f)\n",
            att_size$overall.att, att_size$overall.se,
            2 * pnorm(-abs(att_size$overall.att / att_size$overall.se))))

# Event study
es_size <- aggte(cs_size, type = "dynamic", min_e = -10, max_e = 20)

saveRDS(cs_size, "../data/cs_size_gt.rds")
saveRDS(att_size, "../data/att_size.rds")
saveRDS(es_size, "../data/es_size.rds")

# ============================================================
# C) CALLAWAY-SANT'ANNA: Payroll per Employee (Wage Proxy)
# Note: Labor share (payroll/GDP) cannot be used because FRED nominal
# GDP series start in 1997, leaving no pre-treatment period.
# Instead, use log payroll per employee as a wage-level outcome.
# ============================================================

cat("\n--- CS-DiD: Log Payroll per Employee ---\n")

panel_wage <- panel %>%
  filter(year >= 1988, year <= 2019) %>%
  filter(!is.na(payroll_per_worker), payroll_per_worker > 0) %>%
  mutate(log_wage = log(payroll_per_worker))

cs_wage <- att_gt(
  yname = "log_wage",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = panel_wage,
  control_group = "nevertreated",
  base_period = "universal",
  print_details = FALSE
)

att_wage <- aggte(cs_wage, type = "simple")
cat(sprintf("ATT (log payroll/employee): %.4f (SE: %.4f, p=%.3f)\n",
            att_wage$overall.att, att_wage$overall.se,
            2 * pnorm(-abs(att_wage$overall.att / att_wage$overall.se))))

es_wage <- aggte(cs_wage, type = "dynamic", min_e = -10, max_e = 20)

saveRDS(cs_wage, "../data/cs_wage_gt.rds")
saveRDS(att_wage, "../data/att_wage.rds")
saveRDS(es_wage, "../data/es_wage.rds")

# ============================================================
# D) CALLAWAY-SANT'ANNA: Net Entry Rate (CBP proxy)
# ============================================================

cat("\n--- CS-DiD: Net Entry Rate ---\n")

panel_nr <- panel %>%
  filter(year >= 1989, year <= 2019) %>%
  filter(!is.na(net_entry_rate)) %>%
  # Winsorize extreme values
  mutate(net_entry_rate = pmin(pmax(net_entry_rate, -0.15), 0.15))

cs_nr <- att_gt(
  yname = "net_entry_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = panel_nr,
  control_group = "nevertreated",
  base_period = "universal",
  print_details = FALSE
)

att_nr <- aggte(cs_nr, type = "simple")
cat(sprintf("ATT (net entry rate): %.4f (SE: %.4f, p=%.3f)\n",
            att_nr$overall.att, att_nr$overall.se,
            2 * pnorm(-abs(att_nr$overall.att / att_nr$overall.se))))

es_nr <- aggte(cs_nr, type = "dynamic", min_e = -10, max_e = 20)

saveRDS(cs_nr, "../data/cs_nr_gt.rds")
saveRDS(att_nr, "../data/att_nr.rds")
saveRDS(es_nr, "../data/es_nr.rds")

# ============================================================
# E) CALLAWAY-SANT'ANNA: BDS Entry Rate (if available)
# ============================================================

if ("entry_rate" %in% names(panel)) {
  cat("\n--- CS-DiD: BDS Entry Rate ---\n")

  panel_bds <- panel %>%
    filter(year >= 1980, year <= 2019) %>%
    filter(!is.na(entry_rate))

  if (nrow(panel_bds) > 100) {
    cs_bds <- att_gt(
      yname = "entry_rate",
      tname = "year",
      idname = "state_id",
      gname = "first_treat",
      data = panel_bds,
      control_group = "nevertreated",
      base_period = "universal",
      print_details = FALSE
    )

    att_bds <- aggte(cs_bds, type = "simple")
    cat(sprintf("ATT (BDS entry rate): %.4f (SE: %.4f, p=%.3f)\n",
                att_bds$overall.att, att_bds$overall.se,
                2 * pnorm(-abs(att_bds$overall.att / att_bds$overall.se))))

    es_bds <- aggte(cs_bds, type = "dynamic", min_e = -10, max_e = 20)

    saveRDS(cs_bds, "../data/cs_bds_gt.rds")
    saveRDS(att_bds, "../data/att_bds.rds")
    saveRDS(es_bds, "../data/es_bds.rds")
  }
}

# ============================================================
# F) TWFE BENCHMARK (for Goodman-Bacon decomposition)
# ============================================================

cat("\n--- TWFE benchmark (for decomposition) ---\n")

# Simple TWFE for comparison
twfe_size <- feols(log_avg_size ~ post | state_id + year,
                   data = panel_cs, cluster = ~state_id)
cat("TWFE (log avg estab size):\n")
print(summary(twfe_size))

# Goodman-Bacon decomposition
panel_bacon <- panel_cs %>%
  select(state_id, year, first_treat, log_avg_size, post) %>%
  filter(!is.na(log_avg_size))

tryCatch({
  bacon_out <- bacon(log_avg_size ~ post,
                     data = panel_bacon,
                     id_var = "state_id",
                     time_var = "year")
  saveRDS(bacon_out, "../data/bacon_decomp.rds")
  cat("Bacon decomposition saved.\n")
  cat(sprintf("  Weighted sum: %.4f\n", sum(bacon_out$estimate * bacon_out$weight)))
}, error = function(e) {
  cat(sprintf("Bacon decomposition error: %s\n", e$message))
})

# ============================================================
# G) CALENDAR-TIME AGGREGATION
# ============================================================

cat("\n--- Calendar-time aggregation ---\n")

cal_size <- aggte(cs_size, type = "calendar")
saveRDS(cal_size, "../data/cal_size.rds")

cat("\n=== MAIN ANALYSIS COMPLETE ===\n")
cat("Saved results in ../data/:\n")
cat("  cs_*_gt.rds  — group-time ATTs\n")
cat("  att_*.rds    — aggregate ATTs\n")
cat("  es_*.rds     — event study aggregations\n")
cat("  bacon_decomp.rds — Goodman-Bacon decomposition\n")
