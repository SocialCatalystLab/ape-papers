## ============================================================
## 04_robustness.R — Robustness checks and placebo tests
## Paper: Where Medicaid Goes Dark (apep_0371)
## ============================================================

source("00_packages.R")

cat("\n=== Load Data ===\n")
panel <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
panel <- panel[!is.na(total_pop) & total_pop > 0 &
               state_fips %in% sprintf("%02d", c(1:56))]
panel <- panel[!quarter %in% c("2024Q4")]
panel[, treat_intensity := post_unwind * net_disenroll_pct / 100]

cat("  Panel rows:", nrow(panel), "\n")

cat("\n=== Robustness 1: Alternative Provider Thresholds ===\n")

# Need provider_quarters for this
provider_quarters <- readRDS(file.path(DATA_DIR, "provider_quarters.rds"))
npi_lookup <- readRDS(file.path(DATA_DIR, "npi_lookup.rds"))

# Loose threshold (≥1 claim) — provider_quarters already has county_fips and specialty
pq_loose <- provider_quarters[claims_quarter >= 1]
pq_loose <- pq_loose[!is.na(county_fips)]
panel_loose <- pq_loose[, .(n_providers = uniqueN(npi)),
                           by = .(county_fips, specialty, quarter)]

# Tight threshold (≥12 claims, ~full-time)
pq_tight <- provider_quarters[claims_quarter >= 12]
pq_tight <- pq_tight[!is.na(county_fips)]
panel_tight <- pq_tight[, .(n_providers_tight = uniqueN(npi)),
                           by = .(county_fips, specialty, quarter)]

# Merge loose/tight counts into main panel
panel <- merge(panel, panel_tight,
               by = c("county_fips", "specialty", "quarter"), all.x = TRUE)
panel[is.na(n_providers_tight), n_providers_tight := 0]
panel[, ln_providers_tight := log(n_providers_tight + 1)]

cat("--- Tight threshold (≥12 claims/quarter) ---\n")
rob1 <- feols(ln_providers_tight ~ treat_intensity |
                cs_id + quarter,
              data = panel,
              cluster = ~state_fips)
cat("  Coef:", round(coef(rob1)["treat_intensity"], 4),
    "  SE:", round(se(rob1)["treat_intensity"], 4), "\n")

cat("\n=== Robustness 2: Placebo Test — Pre-Period Fake Treatment ===\n")

# Assign fake unwinding in 2021Q2 (2 years before actual)
panel[, fake_post := quarter >= "2021Q2"]
panel[, fake_treat := fake_post * net_disenroll_pct / 100]

# Restrict to pre-unwinding period only
panel_pre <- panel[quarter < unwind_quarter]

placebo <- feols(ln_providers ~ fake_treat |
                   cs_id + quarter,
                 data = panel_pre,
                 cluster = ~state_fips)
cat("Placebo (fake treatment 2021Q2):\n")
cat("  Coef:", round(coef(placebo)["fake_treat"], 4),
    "  SE:", round(se(placebo)["fake_treat"], 4),
    "  p:", round(fixest::pvalue(placebo)["fake_treat"], 4), "\n")

cat("\n=== Robustness 3: Binary Treatment (Early vs Late) ===\n")

# Early = states starting in 2023Q2 (April-June), Late = 2023Q3+
panel[, early_adopter := unwind_quarter == "2023Q2"]
panel[, treat_binary := post_unwind * early_adopter]

rob3 <- feols(ln_providers ~ treat_binary |
                cs_id + quarter,
              data = panel,
              cluster = ~state_fips)
cat("Binary treatment (early vs late):\n")
cat("  Coef:", round(coef(rob3)["treat_binary"], 4),
    "  SE:", round(se(rob3)["treat_binary"], 4), "\n")

cat("\n=== Robustness 4: Controlling for State Characteristics ===\n")

# Time-varying state controls: interact state characteristics with quarter
panel[, medicaid_share_x_qtr := medicaid_share * qtr_num]

rob4 <- feols(ln_providers ~ treat_intensity + medicaid_share_x_qtr |
                cs_id + quarter,
              data = panel,
              cluster = ~state_fips)
cat("With Medicaid share × time control:\n")
cat("  Coef:", round(coef(rob4)["treat_intensity"], 4),
    "  SE:", round(se(rob4)["treat_intensity"], 4), "\n")

cat("\n=== Robustness 5: NP/PA Substitution ===\n")

# Among counties losing MD/DO primary care, do NP/PA counts increase?
panel_pc <- panel[specialty == "Primary Care" & !is.na(n_md)]
panel_np <- panel[specialty == "NP/PA"]

# MD count in primary care
rob5_md <- feols(log(n_md + 1) ~ treat_intensity |
                   cs_id + quarter,
                 data = panel_pc,
                 cluster = ~state_fips)

# NP/PA count
rob5_np <- feols(ln_providers ~ treat_intensity |
                   cs_id + quarter,
                 data = panel_np,
                 cluster = ~state_fips)

cat("MD Primary Care:\n")
cat("  Coef:", round(coef(rob5_md)["treat_intensity"], 4),
    "  SE:", round(se(rob5_md)["treat_intensity"], 4), "\n")
cat("NP/PA:\n")
cat("  Coef:", round(coef(rob5_np)["treat_intensity"], 4),
    "  SE:", round(se(rob5_np)["treat_intensity"], 4), "\n")

cat("\n=== Robustness 6: Permutation Inference ===\n")

# Randomization inference: permute treatment timing across states
set.seed(42)
n_perms <- 500
observed_coef <- coef(feols(ln_providers ~ treat_intensity | cs_id + quarter,
                            data = panel, cluster = ~state_fips))["treat_intensity"]

perm_coefs <- numeric(n_perms)
states <- unique(panel$state_fips)
actual_timing <- unique(panel[, .(state_fips, unwind_quarter, net_disenroll_pct)])

cat("  Running", n_perms, "permutations...\n")
for (i in seq_len(n_perms)) {
  if (i %% 50 == 0) cat("    Permutation", i, "/", n_perms, "\n")

  # Shuffle treatment assignment across states
  shuffled <- copy(actual_timing)
  shuffled[, unwind_quarter := sample(unwind_quarter)]
  shuffled[, net_disenroll_pct := sample(net_disenroll_pct)]

  panel_perm <- merge(panel[, !c("unwind_quarter", "net_disenroll_pct", "post_unwind",
                                  "treat_intensity"), with = FALSE],
                      shuffled, by = "state_fips")
  panel_perm[, post_unwind := quarter >= unwind_quarter]
  panel_perm[, treat_intensity := post_unwind * net_disenroll_pct / 100]

  tryCatch({
    m_perm <- feols(ln_providers ~ treat_intensity | cs_id + quarter,
                    data = panel_perm, cluster = ~state_fips)
    perm_coefs[i] <- coef(m_perm)["treat_intensity"]
  }, error = function(e) {
    perm_coefs[i] <<- NA
  })
}

perm_coefs <- perm_coefs[!is.na(perm_coefs)]
ri_pvalue <- mean(abs(perm_coefs) >= abs(observed_coef))

cat("  Observed coefficient:", round(observed_coef, 4), "\n")
cat("  RI p-value (two-sided):", round(ri_pvalue, 3), "\n")
cat("  RI 95% CI: [", round(quantile(perm_coefs, 0.025), 4), ",",
    round(quantile(perm_coefs, 0.975), 4), "]\n")

cat("\n=== Save Robustness Results ===\n")

robustness <- list(
  rob1_tight = rob1,
  placebo = placebo,
  rob3_binary = rob3,
  rob4_controls = rob4,
  rob5_md = rob5_md,
  rob5_np = rob5_np,
  ri_pvalue = ri_pvalue,
  ri_observed = observed_coef,
  ri_distribution = perm_coefs
)

saveRDS(robustness, file.path(DATA_DIR, "robustness_results.rds"))
cat("  Saved robustness_results.rds\n")

# Create robustness table
rob_models <- list(
  "Main (≥4 claims)" = feols(ln_providers ~ treat_intensity | cs_id + quarter,
                              data = panel, cluster = ~state_fips),
  "Tight (≥12 claims)" = rob1,
  "Binary treatment" = rob3,
  "With controls" = rob4,
  "Placebo (2021Q2)" = placebo
)

tab_rob <- modelsummary(rob_models,
  output = "latex",
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  coef_map = c("treat_intensity" = "Unwinding Intensity $\\times$ Post",
               "treat_binary" = "Early Adopter $\\times$ Post",
               "fake_treat" = "Placebo $\\times$ Post"),
  gof_map = c("nobs", "r.squared"),
  title = "Robustness Checks: Medicaid Unwinding and Provider Supply",
  notes = list("Clustered standard errors at the state level.",
               "RI p-value for main specification: [filled in text].")
)

tab_rob_chr <- if (is.character(tab_rob)) tab_rob else as.character(tab_rob)
writeLines(tab_rob_chr, file.path(TAB_DIR, "robustness.tex"))
cat("  Saved robustness.tex\n")

cat("\nRobustness checks complete.\n")
