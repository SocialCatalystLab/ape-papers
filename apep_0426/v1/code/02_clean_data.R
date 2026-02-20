## ── 02_clean_data.R ───────────────────────────────────────────────────────
## Clean and prepare analysis-ready panel for apep_0426
## ──────────────────────────────────────────────────────────────────────────

source("00_packages.R")

data_dir <- "../data"

## Load panel
panel <- fread(file.path(data_dir, "analysis_panel.csv"))
cat(sprintf("Raw panel: %d obs, %d districts, years %d-%d\n",
            nrow(panel), uniqueN(panel$dist_code),
            min(panel$year), max(panel$year)))

## ── Winsorize nightlights at 99th percentile ─────────────────────────────
p99 <- quantile(panel$log_light, 0.99, na.rm = TRUE)
p01 <- quantile(panel$log_light, 0.01, na.rm = TRUE)
panel[log_light > p99, log_light := p99]
panel[log_light < p01, log_light := p01]

## ── Create relative time indicators for event study ──────────────────────
## Bin event times: cap at -10 and +15
panel[, event_time_binned := pmax(pmin(event_time, 15), -10)]

## ── Baseline quartiles for heterogeneity ─────────────────────────────────
## Use pre-treatment (2000) nightlights as baseline development
baseline_nl <- panel[year == 2000, .(dist_code, baseline_light = log_light)]
panel <- merge(panel, baseline_nl, by = "dist_code", all.x = TRUE)

## Quartiles of baseline development
panel[, dev_quartile := cut(baseline_light,
                             breaks = quantile(baseline_light, probs = 0:4/4, na.rm = TRUE),
                             labels = c("Q1 (darkest)", "Q2", "Q3", "Q4 (brightest)"),
                             include.lowest = TRUE)]

## ── SC/ST intensity quartiles ────────────────────────────────────────────
panel[, scst_quartile := cut(sc_st_share,
                              breaks = quantile(sc_st_share, probs = 0:4/4, na.rm = TRUE),
                              labels = c("Q1 (low SC/ST)", "Q2", "Q3", "Q4 (high SC/ST)"),
                              include.lowest = TRUE)]

## ── Summary statistics ───────────────────────────────────────────────────
cat("\n=== Summary Statistics ===\n")
cat(sprintf("Districts: %d\n", uniqueN(panel$dist_code)))
cat(sprintf("  Phase I:   %d\n", uniqueN(panel[nrega_phase == 1, dist_code])))
cat(sprintf("  Phase II:  %d\n", uniqueN(panel[nrega_phase == 2, dist_code])))
cat(sprintf("  Phase III: %d\n", uniqueN(panel[nrega_phase == 3, dist_code])))
cat(sprintf("Years: %d-%d\n", min(panel$year), max(panel$year)))
cat(sprintf("Panel observations: %d\n", nrow(panel)))

cat("\nMean log(nightlights) by phase and period:\n")
print(panel[, .(
  mean_log_light = round(mean(log_light, na.rm = TRUE), 3),
  sd_log_light   = round(sd(log_light, na.rm = TRUE), 3),
  n_obs          = .N
), by = .(nrega_phase, period = fifelse(year < 2006, "Pre-2006",
                                         fifelse(year < 2008, "2006-07", "Post-2008")))
][order(nrega_phase, period)])

## ── Cross-sectional structural transformation data ───────────────────────
cross <- fread(file.path(data_dir, "district_cross_section.csv"))

## Compute structural transformation metrics
cross[main_workers_2001 > 0 & main_workers_2011 > 0, `:=`(
  nonfarm_share_01 = (hh_industry_2001 + other_workers_2001) / main_workers_2001,
  nonfarm_share_11 = (hh_industry_2011 + other_workers_2011) / main_workers_2011,
  agri_share_01    = (cultivators_2001 + agri_labor_2001) / main_workers_2001,
  agri_share_11    = (cultivators_2011 + agri_labor_2011) / main_workers_2011
)]

cross[, `:=`(
  delta_nonfarm = nonfarm_share_11 - nonfarm_share_01,
  delta_agri    = agri_share_11 - agri_share_01,
  pop_growth    = log(pop_2011) - log(pop_2001)
)]

fwrite(cross, file.path(data_dir, "district_cross_section.csv"))

## Save cleaned panel
fwrite(panel, file.path(data_dir, "analysis_panel_clean.csv"))

cat("\n✓ Clean panel saved.\n")
