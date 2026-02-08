## 03_main_analysis.R — Primary DiD analysis
## Paper 109: Must-Access PDMP Mandates and Employment

source("00_packages.R")

data_dir <- "../data"
panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))

cat("=== MAIN ANALYSIS ===\n")
cat(sprintf("Panel: %d state-years, %d states, %d-%d\n",
            nrow(panel), n_distinct(panel$statefip),
            min(panel$year), max(panel$year)))

###############################################################################
## 1. Callaway-Sant'Anna (Primary Specification)
###############################################################################

cat("\n=== 1. Callaway-Sant'Anna DiD ===\n")

cs_log_emp <- att_gt(
  yname = "log_emp",
  tname = "year",
  idname = "statefip",
  gname = "first_treat",
  data = panel,
  control_group = "nevertreated",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000,
  anticipation = 1
)

cat("CS-DiD ATT(g,t) complete.\n")

att_overall <- aggte(cs_log_emp, type = "simple")
cat(sprintf("\nOverall ATT (log emp): %.4f (SE: %.4f)\n",
            att_overall$overall.att, att_overall$overall.se))
cat(sprintf("  95%% CI: [%.4f, %.4f]\n",
            att_overall$overall.att - 1.96 * att_overall$overall.se,
            att_overall$overall.att + 1.96 * att_overall$overall.se))

att_group <- aggte(cs_log_emp, type = "group")
cat("\nGroup ATT:\n")
summary(att_group)

att_dynamic <- aggte(cs_log_emp, type = "dynamic", min_e = -6, max_e = 6)
cat("\nDynamic ATT:\n")
summary(att_dynamic)

saveRDS(cs_log_emp, file.path(data_dir, "cs_log_emp.rds"))
saveRDS(att_overall, file.path(data_dir, "att_overall_log_emp.rds"))
saveRDS(att_group, file.path(data_dir, "att_group_log_emp.rds"))
saveRDS(att_dynamic, file.path(data_dir, "att_dynamic_log_emp.rds"))

###############################################################################
## 2. Unemployment rate
###############################################################################

cat("\n=== 2. CS-DiD: Unemployment Rate ===\n")

cs_unemp <- att_gt(
  yname = "unemp_rate_march",
  tname = "year",
  idname = "statefip",
  gname = "first_treat",
  data = panel,
  control_group = "nevertreated",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000,
  anticipation = 1
)

att_overall_ur <- aggte(cs_unemp, type = "simple")
cat(sprintf("Overall ATT (unemp rate): %.4f (SE: %.4f)\n",
            att_overall_ur$overall.att, att_overall_ur$overall.se))

att_dynamic_ur <- aggte(cs_unemp, type = "dynamic", min_e = -6, max_e = 6)

saveRDS(cs_unemp, file.path(data_dir, "cs_unemp.rds"))
saveRDS(att_overall_ur, file.path(data_dir, "att_overall_unemp.rds"))
saveRDS(att_dynamic_ur, file.path(data_dir, "att_dynamic_unemp.rds"))

###############################################################################
## 3. Employment rate
###############################################################################

cat("\n=== 3. CS-DiD: Employment Rate ===\n")

cs_emp_rate <- att_gt(
  yname = "emp_rate",
  tname = "year",
  idname = "statefip",
  gname = "first_treat",
  data = panel,
  control_group = "nevertreated",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000,
  anticipation = 1
)

att_overall_er <- aggte(cs_emp_rate, type = "simple")
cat(sprintf("Overall ATT (emp rate): %.4f (SE: %.4f)\n",
            att_overall_er$overall.att, att_overall_er$overall.se))

att_dynamic_er <- aggte(cs_emp_rate, type = "dynamic", min_e = -6, max_e = 6)

saveRDS(cs_emp_rate, file.path(data_dir, "cs_emp_rate.rds"))
saveRDS(att_overall_er, file.path(data_dir, "att_overall_emp_rate.rds"))
saveRDS(att_dynamic_er, file.path(data_dir, "att_dynamic_emp_rate.rds"))

###############################################################################
## 4. TWFE comparison
###############################################################################

cat("\n=== 4. TWFE Comparison ===\n")

twfe_log_emp <- feols(log_emp ~ treated | statefip + year, data = panel, cluster = ~statefip)
twfe_unemp <- feols(unemp_rate_march ~ treated | statefip + year, data = panel, cluster = ~statefip)
twfe_emp_rate <- feols(emp_rate ~ treated | statefip + year, data = panel, cluster = ~statefip)

cat(sprintf("  log(emp):   %+.4f (%.4f)\n", coef(twfe_log_emp), se(twfe_log_emp)))
cat(sprintf("  unemp rate: %+.4f (%.4f)\n", coef(twfe_unemp), se(twfe_unemp)))
cat(sprintf("  emp rate:   %+.4f (%.4f)\n", coef(twfe_emp_rate), se(twfe_emp_rate)))

saveRDS(twfe_log_emp, file.path(data_dir, "twfe_log_emp.rds"))
saveRDS(twfe_unemp, file.path(data_dir, "twfe_unemp.rds"))
saveRDS(twfe_emp_rate, file.path(data_dir, "twfe_emp_rate.rds"))

###############################################################################
## 5. TWFE with policy controls
###############################################################################

cat("\n=== 5. TWFE + Policy Controls ===\n")

twfe_ctrl <- feols(
  log_emp ~ treated + medicaid_expanded + rec_marijuana_legal | statefip + year,
  data = panel, cluster = ~statefip
)
cat(sprintf("  Treated coef: %+.4f (%.4f)\n",
            coef(twfe_ctrl)["treated"], se(twfe_ctrl)["treated"]))

saveRDS(twfe_ctrl, file.path(data_dir, "twfe_controls.rds"))

###############################################################################
## Summary
###############################################################################

cat("\n========================================\n")
cat("RESULTS SUMMARY\n")
cat("========================================\n")
p_fn <- function(est, se) 2 * pnorm(-abs(est/se))
cat(sprintf("CS-DiD (log emp):    %+.4f (%.4f), p=%.3f\n",
            att_overall$overall.att, att_overall$overall.se,
            p_fn(att_overall$overall.att, att_overall$overall.se)))
cat(sprintf("CS-DiD (unemp rate): %+.4f (%.4f), p=%.3f\n",
            att_overall_ur$overall.att, att_overall_ur$overall.se,
            p_fn(att_overall_ur$overall.att, att_overall_ur$overall.se)))
cat(sprintf("CS-DiD (emp rate):   %+.4f (%.4f), p=%.3f\n",
            att_overall_er$overall.att, att_overall_er$overall.se,
            p_fn(att_overall_er$overall.att, att_overall_er$overall.se)))
cat(sprintf("TWFE (log emp):      %+.4f (%.4f)\n",
            coef(twfe_log_emp), se(twfe_log_emp)))
cat("========================================\n")
