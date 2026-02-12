## =============================================================================
## 03_main_analysis.R — Callaway-Sant'Anna DiD estimation
## APEP Working Paper apep_0232
## =============================================================================

source("00_packages.R")

data_dir <- "../data"
panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))

cat("=== Main Analysis: IMLC and Healthcare Employment ===\n\n")

## ---------------------------------------------------------------------------
## 1. Callaway-Sant'Anna: Healthcare Employment (NAICS 62)
## ---------------------------------------------------------------------------

cat("--- CS DiD: Log Healthcare Employment ---\n")

cs_hc_emp <- att_gt(
  yname  = "log_hc_emp",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel %>% filter(!is.na(log_hc_emp)),
  control_group = "nevertreated",
  base_period = "universal"
)

cat("Group-time ATTs computed.\n")

# Overall ATT
agg_hc_emp <- aggte(cs_hc_emp, type = "simple")
cat(sprintf("Overall ATT (Healthcare Employment): %.4f (SE: %.4f, p: %.4f)\n",
            agg_hc_emp$overall.att, agg_hc_emp$overall.se,
            2 * pnorm(-abs(agg_hc_emp$overall.att / agg_hc_emp$overall.se))))

# Event study
es_hc_emp <- aggte(cs_hc_emp, type = "dynamic", min_e = -5, max_e = 6)

## ---------------------------------------------------------------------------
## 2. CS DiD: Ambulatory Healthcare Employment (NAICS 621)
## ---------------------------------------------------------------------------

cat("\n--- CS DiD: Log Ambulatory Employment ---\n")

cs_amb_emp <- att_gt(
  yname  = "log_amb_emp",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel %>% filter(!is.na(log_amb_emp)),
  control_group = "nevertreated",
  base_period = "universal"
)

agg_amb_emp <- aggte(cs_amb_emp, type = "simple")
cat(sprintf("Overall ATT (Ambulatory Employment): %.4f (SE: %.4f, p: %.4f)\n",
            agg_amb_emp$overall.att, agg_amb_emp$overall.se,
            2 * pnorm(-abs(agg_amb_emp$overall.att / agg_amb_emp$overall.se))))

es_amb_emp <- aggte(cs_amb_emp, type = "dynamic", min_e = -5, max_e = 6)

## ---------------------------------------------------------------------------
## 3. CS DiD: Healthcare Establishments
## ---------------------------------------------------------------------------

cat("\n--- CS DiD: Log Healthcare Establishments ---\n")

cs_hc_estabs <- att_gt(
  yname  = "log_hc_estabs",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel %>% filter(!is.na(log_hc_estabs)),
  control_group = "nevertreated",
  base_period = "universal"
)

agg_hc_estabs <- aggte(cs_hc_estabs, type = "simple")
cat(sprintf("Overall ATT (Healthcare Establishments): %.4f (SE: %.4f, p: %.4f)\n",
            agg_hc_estabs$overall.att, agg_hc_estabs$overall.se,
            2 * pnorm(-abs(agg_hc_estabs$overall.att / agg_hc_estabs$overall.se))))

es_hc_estabs <- aggte(cs_hc_estabs, type = "dynamic", min_e = -5, max_e = 6)

## ---------------------------------------------------------------------------
## 4. CS DiD: Average Annual Pay
## ---------------------------------------------------------------------------

cat("\n--- CS DiD: Log Avg Annual Pay (Healthcare) ---\n")

cs_hc_pay <- att_gt(
  yname  = "log_hc_avgpay",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel %>% filter(!is.na(log_hc_avgpay)),
  control_group = "nevertreated",
  base_period = "universal"
)

agg_hc_pay <- aggte(cs_hc_pay, type = "simple")
cat(sprintf("Overall ATT (Avg Annual Pay): %.4f (SE: %.4f, p: %.4f)\n",
            agg_hc_pay$overall.att, agg_hc_pay$overall.se,
            2 * pnorm(-abs(agg_hc_pay$overall.att / agg_hc_pay$overall.se))))

es_hc_pay <- aggte(cs_hc_pay, type = "dynamic", min_e = -5, max_e = 6)

## ---------------------------------------------------------------------------
## 5. CS DiD: Ambulatory Establishments
## ---------------------------------------------------------------------------

cat("\n--- CS DiD: Log Ambulatory Establishments ---\n")

cs_amb_estabs <- att_gt(
  yname  = "log_amb_estabs",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel %>% filter(!is.na(log_amb_estabs)),
  control_group = "nevertreated",
  base_period = "universal"
)

agg_amb_estabs <- aggte(cs_amb_estabs, type = "simple")
cat(sprintf("Overall ATT (Ambulatory Establishments): %.4f (SE: %.4f, p: %.4f)\n",
            agg_amb_estabs$overall.att, agg_amb_estabs$overall.se,
            2 * pnorm(-abs(agg_amb_estabs$overall.att / agg_amb_estabs$overall.se))))

es_amb_estabs <- aggte(cs_amb_estabs, type = "dynamic", min_e = -5, max_e = 6)

## ---------------------------------------------------------------------------
## 6. TWFE (for comparison only — potentially biased with staggered adoption)
## ---------------------------------------------------------------------------

cat("\n--- TWFE Comparison ---\n")

twfe_hc <- feols(log_hc_emp ~ treated | state_id + year,
                 data = panel, cluster = ~state_id)
cat("TWFE Healthcare Employment:\n")
print(summary(twfe_hc))

twfe_amb <- feols(log_amb_emp ~ treated | state_id + year,
                  data = panel, cluster = ~state_id)
cat("\nTWFE Ambulatory Employment:\n")
print(summary(twfe_amb))

twfe_estabs <- feols(log_hc_estabs ~ treated | state_id + year,
                     data = panel, cluster = ~state_id)
cat("\nTWFE Healthcare Establishments:\n")
print(summary(twfe_estabs))

twfe_pay <- feols(log_hc_avgpay ~ treated | state_id + year,
                  data = panel, cluster = ~state_id)
cat("\nTWFE Avg Annual Pay:\n")
print(summary(twfe_pay))

twfe_amb_estabs <- feols(log_amb_estabs ~ treated | state_id + year,
                         data = panel %>% filter(!is.na(log_amb_estabs)),
                         cluster = ~state_id)
cat("\nTWFE Ambulatory Establishments:\n")
print(summary(twfe_amb_estabs))

## ---------------------------------------------------------------------------
## 7. Sun-Abraham event study
## ---------------------------------------------------------------------------

cat("\n--- Sun-Abraham Event Study ---\n")

# Create relative time variable
panel <- panel %>%
  mutate(rel_time = ifelse(first_treat > 0, year - first_treat, -1000))

sa_hc <- feols(log_hc_emp ~ sunab(first_treat, year) | state_id + year,
               data = panel %>% filter(first_treat != 2024),  # Drop thin 2024 cohort
               cluster = ~state_id)
cat("Sun-Abraham Healthcare Employment:\n")
print(summary(sa_hc))

sa_amb <- feols(log_amb_emp ~ sunab(first_treat, year) | state_id + year,
                data = panel %>% filter(first_treat != 2024),
                cluster = ~state_id)
cat("\nSun-Abraham Ambulatory Employment:\n")
print(summary(sa_amb))

## ---------------------------------------------------------------------------
## 8. Save all results
## ---------------------------------------------------------------------------

results <- list(
  # CS estimates
  cs_hc_emp     = cs_hc_emp,
  cs_amb_emp    = cs_amb_emp,
  cs_hc_estabs  = cs_hc_estabs,
  cs_hc_pay     = cs_hc_pay,
  cs_amb_estabs = cs_amb_estabs,

  # CS aggregates
  agg_hc_emp     = agg_hc_emp,
  agg_amb_emp    = agg_amb_emp,
  agg_hc_estabs  = agg_hc_estabs,
  agg_hc_pay     = agg_hc_pay,
  agg_amb_estabs = agg_amb_estabs,

  # CS event studies
  es_hc_emp     = es_hc_emp,
  es_amb_emp    = es_amb_emp,
  es_hc_estabs  = es_hc_estabs,
  es_hc_pay     = es_hc_pay,
  es_amb_estabs = es_amb_estabs,

  # TWFE
  twfe_hc    = twfe_hc,
  twfe_amb   = twfe_amb,
  twfe_estabs = twfe_estabs,
  twfe_pay   = twfe_pay,
  twfe_amb_estabs = twfe_amb_estabs,

  # Sun-Abraham
  sa_hc  = sa_hc,
  sa_amb = sa_amb,

  # Panel data
  panel  = panel
)

saveRDS(results, file.path(data_dir, "main_results.rds"))

# Save key estimates for tables
estimates_table <- tibble(
  Outcome = c("Healthcare Employment", "Ambulatory Employment",
              "Healthcare Establishments", "Avg Annual Pay",
              "Ambulatory Establishments"),
  CS_ATT = c(agg_hc_emp$overall.att, agg_amb_emp$overall.att,
             agg_hc_estabs$overall.att, agg_hc_pay$overall.att,
             agg_amb_estabs$overall.att),
  CS_SE = c(agg_hc_emp$overall.se, agg_amb_emp$overall.se,
            agg_hc_estabs$overall.se, agg_hc_pay$overall.se,
            agg_amb_estabs$overall.se),
  CS_pval = 2 * pnorm(-abs(CS_ATT / CS_SE)),
  TWFE_coef = c(coef(twfe_hc)["treated"], coef(twfe_amb)["treated"],
                coef(twfe_estabs)["treated"], coef(twfe_pay)["treated"], NA),
  TWFE_SE = c(se(twfe_hc)["treated"], se(twfe_amb)["treated"],
              se(twfe_estabs)["treated"], se(twfe_pay)["treated"], NA)
)

write_csv(estimates_table, file.path(data_dir, "estimates_table.csv"))

cat("\n=== Main analysis complete. Results saved. ===\n")
