## =============================================================================
## 04b_reviewer_robustness.R — Additional robustness checks (reviewer-requested)
## =============================================================================

source(here::here("output", "apep_0214", "v1", "code", "00_packages.R"))

data_dir <- file.path(base_dir, "data")
tab_dir  <- file.path(base_dir, "tables")

panel_soft <- read_csv(file.path(data_dir, "panel_software.csv"), show_col_types = FALSE)

# ==== 1. Formal Pre-Trend Joint Test (Software Publishers) ====
cat("=== Pre-Trend Joint Test ===\n")

main_results <- readRDS(file.path(data_dir, "main_results.rds"))

# The CS package stores pre-test info
cs_soft <- main_results$cs_soft
cat("Pre-test from CS object:\n")
print(cs_soft$Wpval)  # Wald test p-value for pre-trends

# Also compute manually from the event study
es_soft <- main_results$es_soft
pre_idx <- which(es_soft$egt < 0)
pre_atts <- es_soft$att.egt[pre_idx]
pre_ses <- es_soft$se.egt[pre_idx]
# Joint Wald test: sum of (att/se)^2 ~ chi-sq with df = number of pre-periods
wald_stat <- sum((pre_atts / pre_ses)^2, na.rm = TRUE)
df_pre <- sum(!is.na(pre_atts / pre_ses))
wald_pval <- pchisq(wald_stat, df = df_pre, lower.tail = FALSE)
cat(sprintf("Manual Wald pre-test: chi2(%d) = %.3f, p = %.4f\n", df_pre, wald_stat, wald_pval))


# ==== 2. Exclude California Robustness ====
cat("\n=== Exclude California ===\n")

panel_no_ca <- panel_soft %>% filter(state_abbr != "CA")
cat(sprintf("Panel without CA: %d obs, %d states\n", nrow(panel_no_ca), n_distinct(panel_no_ca$state_abbr)))

cs_no_ca <- tryCatch({
  att_gt(
    yname = "log_emp",
    tname = "period",
    idname = "state_id",
    gname = "first_treat",
    data = panel_no_ca %>% filter(!is.na(log_emp)),
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 500
  )
}, error = function(e) { cat(sprintf("Error: %s\n", e$message)); NULL })

if (!is.null(cs_no_ca)) {
  att_no_ca <- aggte(cs_no_ca, type = "simple")
  cat("ATT excluding California:\n")
  summary(att_no_ca)
}


# ==== 3. Not-Yet-Treated Controls ====
cat("\n=== Not-Yet-Treated Controls ===\n")

cs_nyt <- tryCatch({
  att_gt(
    yname = "log_emp",
    tname = "period",
    idname = "state_id",
    gname = "first_treat",
    data = panel_soft %>% filter(!is.na(log_emp)),
    control_group = "notyettreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 500
  )
}, error = function(e) { cat(sprintf("Error: %s\n", e$message)); NULL })

if (!is.null(cs_nyt)) {
  att_nyt <- aggte(cs_nyt, type = "simple")
  cat("ATT with not-yet-treated controls:\n")
  summary(att_nyt)
}


# ==== 4. Save additional results ====
addl_rob <- list(
  wald_stat = wald_stat,
  wald_df = df_pre,
  wald_pval = wald_pval,
  cs_pretest_pval = cs_soft$Wpval,
  att_no_ca = if (!is.null(cs_no_ca)) att_no_ca else NULL,
  att_nyt = if (!is.null(cs_nyt)) att_nyt else NULL
)

saveRDS(addl_rob, file.path(data_dir, "reviewer_robustness.rds"))
cat("\n=== Additional robustness checks complete ===\n")
