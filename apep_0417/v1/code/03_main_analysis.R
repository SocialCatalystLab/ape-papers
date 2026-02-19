## ============================================================
## 03_main_analysis.R — Main DiD results: unwinding → provider exit
## Paper: Where Medicaid Goes Dark (apep_0371)
## ============================================================

source("00_packages.R")

cat("\n=== Load Analysis Panel ===\n")
panel <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
unwinding <- readRDS(file.path(DATA_DIR, "unwinding_treatment.rds"))

cat("  Panel rows:", nrow(panel), "\n")
cat("  Panel with population:", sum(!is.na(panel$total_pop)), "\n")

# Restrict to counties with population data and US states (exclude territories)
panel <- panel[!is.na(total_pop) & total_pop > 0 &
               state_fips %in% sprintf("%02d", c(1:56))]

# Exclude 2024Q4 if present
panel <- panel[!quarter %in% c("2024Q4")]

cat("  After restrictions:", nrow(panel), "\n")

cat("\n=== Table 1: Summary Statistics ===\n")

# Panel A: Provider counts by specialty across all county-quarters
sumstats <- panel[, .(
  obs = .N,
  counties = uniqueN(county_fips),
  mean_providers = round(mean(n_providers), 2),
  sd_providers = round(sd(n_providers), 2),
  median_providers = median(n_providers),
  pct_zero = round(100 * mean(n_providers == 0), 1),
  mean_per_10k = round(mean(providers_per_10k, na.rm = TRUE), 3),
  pct_desert = round(100 * mean(is_desert, na.rm = TRUE), 1)
), by = specialty]

cat("Summary by specialty:\n")
print(sumstats[order(-mean_providers)])

# Save Table 1
fwrite(sumstats[order(-mean_providers)], file.path(TAB_DIR, "summary_stats.csv"))

cat("\n=== Table 2: National Provider Trends ===\n")

# Providers by specialty × year (national totals)
trends <- panel[, .(
  active_providers = sum(n_providers),
  counties_with_any = sum(n_providers > 0),
  total_claims = sum(total_claims),
  total_benes = sum(total_benes)
), by = .(specialty, year)]

# Compute year-over-year change
trends <- trends[order(specialty, year)]
trends[, prov_change := active_providers / shift(active_providers) - 1, by = specialty]
trends[, prov_change_pct := round(prov_change * 100, 1)]

cat("Provider trends:\n")
print(dcast(trends, specialty ~ year, value.var = "active_providers"))

fwrite(trends, file.path(TAB_DIR, "provider_trends.csv"))

cat("\n=== Main Specification: Unwinding DiD ===\n")

# Specification 1: Pooled across specialties
# Y = ln(providers + 1) ~ post × intensity | county_specialty + quarter
panel[, treat_intensity := post_unwind * net_disenroll_pct / 100]

cat("\n--- Model 1: Pooled OLS with county-specialty and quarter FE ---\n")
m1 <- feols(ln_providers ~ treat_intensity |
              cs_id + quarter,
            data = panel,
            cluster = ~state_fips)
cat("Model 1 (pooled):\n")
print(summary(m1))

cat("\n--- Model 2: By specialty ---\n")
m2 <- feols(ln_providers ~ treat_intensity |
              cs_id + quarter,
            data = panel,
            cluster = ~state_fips,
            split = ~specialty)
cat("Model 2 (by specialty):\n")
# fixest_multi must be indexed by integer, not character
m2_list <- list()
for (i in seq_along(m2)) {
  nm <- names(m2)[i]
  m2_list[[nm]] <- m2[[i]]
  cat("\n  ", nm, ":\n")
  cat("    Coef:", round(coef(m2[[i]])["treat_intensity"], 4),
      "  SE:", round(se(m2[[i]])["treat_intensity"], 4),
      "  p:", round(fixest::pvalue(m2[[i]])["treat_intensity"], 4), "\n")
}

cat("\n--- Model 3: Extensive margin (desert indicator) ---\n")
m3 <- feols(is_desert ~ treat_intensity |
              cs_id + quarter,
            data = panel,
            cluster = ~state_fips)
cat("Model 3 (desert indicator):\n")
print(summary(m3))

cat("\n--- Model 4: Urban vs Rural ---\n")
m4_urban <- feols(ln_providers ~ treat_intensity |
                    cs_id + quarter,
                  data = panel[urban == TRUE],
                  cluster = ~state_fips)
m4_rural <- feols(ln_providers ~ treat_intensity |
                    cs_id + quarter,
                  data = panel[urban == FALSE],
                  cluster = ~state_fips)
cat("Urban:\n")
cat("  Coef:", round(coef(m4_urban)["treat_intensity"], 4),
    "  SE:", round(se(m4_urban)["treat_intensity"], 4), "\n")
cat("Rural:\n")
cat("  Coef:", round(coef(m4_rural)["treat_intensity"], 4),
    "  SE:", round(se(m4_rural)["treat_intensity"], 4), "\n")

cat("\n=== Sun-Abraham Decomposition ===\n")

# Create numeric cohort variable for sunab()
panel[, cohort_quarter := as.integer(factor(unwind_quarter,
                                             levels = sort(unique(unwind_quarter))))]
m_sa <- feols(ln_providers ~ sunab(cohort_quarter, qtr_num) |
                cs_id + quarter,
              data = panel,
              cluster = ~state_fips)
cat("Sun-Abraham decomposition:\n")
sa_agg <- summary(m_sa, agg = "ATT")
cat("  ATT:", round(coef(sa_agg), 4), "\n")
print(summary(m_sa, agg = "ATT"))

cat("\n=== Event Study ===\n")

# Create relative time to unwinding
panel[, rel_quarter := qtr_num - as.integer(factor(unwind_quarter,
                                                     levels = sort(unique(quarter))))]

# Event study specification
# Reference period: rel_quarter = -1
panel[, rel_quarter_fct := relevel(factor(rel_quarter), ref = "-1")]

# Keep reasonable window: -8 to +5
panel_es <- panel[rel_quarter >= -8 & rel_quarter <= 5]

m_es <- feols(ln_providers ~ i(rel_quarter, net_disenroll_pct / 100, ref = -1) |
                cs_id + quarter,
              data = panel_es,
              cluster = ~state_fips)

cat("Event study model:\n")
print(summary(m_es))

# By specialty event studies
specialties <- unique(panel$specialty)
es_results <- list()
for (spec in specialties) {
  sub <- panel_es[specialty == spec]
  if (nrow(sub) > 100) {
    tryCatch({
      m_spec <- feols(ln_providers ~ i(rel_quarter, net_disenroll_pct / 100, ref = -1) |
                        cs_id + quarter,
                      data = sub,
                      cluster = ~state_fips)
      es_results[[spec]] <- m_spec
    }, error = function(e) {
      cat("  Event study failed for", spec, ":", e$message, "\n")
    })
  }
}

cat("  Event studies computed for:", paste(names(es_results), collapse = ", "), "\n")

cat("\n=== Save Results ===\n")

results <- list(
  m1 = m1, m2 = m2_list, m3 = m3,
  m4_urban = m4_urban, m4_rural = m4_rural,
  m_sa = m_sa,
  m_es = m_es, es_results = es_results,
  sumstats = sumstats, trends = trends
)

saveRDS(results, file.path(DATA_DIR, "main_results.rds"))
cat("  Saved main_results.rds\n")

# Create regression table
models_for_table <- list(
  "Pooled" = m1,
  "Desert (ext. margin)" = m3,
  "Urban" = m4_urban,
  "Rural" = m4_rural
)

tab <- modelsummary(models_for_table,
  output = "latex",
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  coef_map = c("treat_intensity" = "Unwinding Intensity $\\times$ Post"),
  gof_map = c("nobs", "r.squared", "adj.r.squared"),
  title = "Effect of Medicaid Unwinding on Provider Supply",
  notes = list("Clustered standard errors at the state level in parentheses.",
               "Unwinding intensity = cumulative net disenrollment rate.",
               "Desert = county-specialty with <1 provider per 10,000 population.")
)

# modelsummary may return tinytable object; convert to character
tab_chr <- if (is.character(tab)) tab else as.character(tab)
writeLines(tab_chr, file.path(TAB_DIR, "main_results.tex"))
cat("  Saved main_results.tex\n")

cat("\nMain analysis complete.\n")
