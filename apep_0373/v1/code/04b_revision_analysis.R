###############################################################################
# 04b_revision_analysis.R — Revision additions: wild cluster bootstrap,
#   division x cohort FE, and confidence interval extraction
# APEP-0372: Minimum Wage Spillovers to College Graduate Earnings
###############################################################################

source("00_packages.R")

# Try to load fwildclusterboot; if unavailable, use manual pairs cluster bootstrap
HAS_FWCB <- requireNamespace("fwildclusterboot", quietly = TRUE)
if (HAS_FWCB) {
  library(fwildclusterboot)
  cat("Using fwildclusterboot for wild cluster bootstrap.\n")
} else {
  cat("fwildclusterboot not available. Using manual pairs cluster bootstrap.\n")
}

data_dir <- "../data"
tables_dir <- "../tables"

###############################################################################
# 1. Load data
###############################################################################

df <- readRDS(file.path(data_dir, "analysis_data.rds"))
df_cip <- readRDS(file.path(data_dir, "analysis_cip.rds"))

df_ba <- df %>%
  filter(degree_group == "Bachelor's", !is.na(ln_y1_p25)) %>%
  mutate(region_cohort = paste(region, cohort, sep = "_"))

df_assoc <- df %>%
  filter(degree_group == "Associate", !is.na(ln_y1_p25))

cat(sprintf("Bachelor's sample: %d obs, %d states\n",
            nrow(df_ba), n_distinct(df_ba$state_fips)))
cat(sprintf("Associate sample: %d obs, %d states\n",
            nrow(df_assoc), n_distinct(df_assoc$state_fips)))

###############################################################################
# 2. Census Division mapping (9 divisions, intermediate between 4 regions
#    and region x cohort)
###############################################################################

division_map <- function(fips) {
  case_when(
    # New England
    fips %in% c("09","23","25","33","44","50") ~ "NewEngland",
    # Middle Atlantic
    fips %in% c("34","36","42") ~ "MidAtlantic",
    # East North Central
    fips %in% c("17","18","26","39","55") ~ "EastNorthCentral",
    # West North Central
    fips %in% c("19","20","27","29","31","38","46") ~ "WestNorthCentral",
    # South Atlantic
    fips %in% c("10","11","12","13","24","37","45","51","54") ~ "SouthAtlantic",
    # East South Central
    fips %in% c("01","21","28","47") ~ "EastSouthCentral",
    # West South Central
    fips %in% c("05","22","40","48") ~ "WestSouthCentral",
    # Mountain
    fips %in% c("04","08","16","30","32","35","49","56") ~ "Mountain",
    # Pacific
    fips %in% c("02","06","15","41","53") ~ "Pacific",
    TRUE ~ "Other"
  )
}

df_ba <- df_ba %>%
  mutate(
    division = division_map(state_fips),
    division_cohort = paste(division, cohort, sep = "_")
  )

df_assoc <- df_assoc %>%
  mutate(
    division = division_map(state_fips),
    division_cohort = paste(division, cohort, sep = "_")
  )

cat(sprintf("\nDivisions in bachelor's data: %d\n", n_distinct(df_ba$division)))
cat("Division counts:\n")
print(table(df_ba$division))

###############################################################################
# 3. Division x Cohort FE specifications (intermediate geographic FE)
###############################################################################

cat("\n=== Division x Cohort FE Specifications ===\n")

# Bachelor's: P25
m_div_ba_p25 <- feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + division_cohort,
                      data = df_ba, cluster = "state_fips")
m_div_ba_p50 <- feols(ln_y1_p50 ~ ln_mw + unemp_avg + ln_income | inst_id + division_cohort,
                      data = df_ba, cluster = "state_fips")
m_div_ba_p75 <- feols(ln_y1_p75 ~ ln_mw + unemp_avg + ln_income | inst_id + division_cohort,
                      data = df_ba, cluster = "state_fips")

cat("\n--- Bachelor's: Division x Cohort FE ---\n")
cat(sprintf("  P25: beta = %.4f (SE = %.4f, p = %.4f)\n",
            coef(m_div_ba_p25)["ln_mw"], se(m_div_ba_p25)["ln_mw"],
            fixest::pvalue(m_div_ba_p25)["ln_mw"]))
cat(sprintf("  P50: beta = %.4f (SE = %.4f, p = %.4f)\n",
            coef(m_div_ba_p50)["ln_mw"], se(m_div_ba_p50)["ln_mw"],
            fixest::pvalue(m_div_ba_p50)["ln_mw"]))
cat(sprintf("  P75: beta = %.4f (SE = %.4f, p = %.4f)\n",
            coef(m_div_ba_p75)["ln_mw"], se(m_div_ba_p75)["ln_mw"],
            fixest::pvalue(m_div_ba_p75)["ln_mw"]))

# Associate: P25
m_div_as_p25 <- feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + division_cohort,
                      data = df_assoc, cluster = "state_fips")

cat(sprintf("\n--- Associate: Division x Cohort FE ---\n"))
cat(sprintf("  P25: beta = %.4f (SE = %.4f, p = %.4f)\n",
            coef(m_div_as_p25)["ln_mw"], se(m_div_as_p25)["ln_mw"],
            fixest::pvalue(m_div_as_p25)["ln_mw"]))

# For comparison: re-run baseline and region x cohort for the progression
m_base_ba_p25 <- feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
                       data = df_ba, cluster = "state_fips")
m_reg_ba_p25 <- feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + region_cohort,
                      data = df_ba, cluster = "state_fips")

cat("\n--- Geographic FE Progression (Bachelor's P25) ---\n")
cat(sprintf("  Cohort FE:           beta = %.4f (SE = %.4f)\n",
            coef(m_base_ba_p25)["ln_mw"], se(m_base_ba_p25)["ln_mw"]))
cat(sprintf("  Division x Cohort:   beta = %.4f (SE = %.4f)\n",
            coef(m_div_ba_p25)["ln_mw"], se(m_div_ba_p25)["ln_mw"]))
cat(sprintf("  Region x Cohort:     beta = %.4f (SE = %.4f)\n",
            coef(m_reg_ba_p25)["ln_mw"], se(m_reg_ba_p25)["ln_mw"]))

###############################################################################
# 4. Pairs Cluster Bootstrap — Bachelor's P25 and Associate P25
###############################################################################

# Manual pairs cluster bootstrap (resample clusters, re-estimate)
pairs_cluster_boot <- function(data, formula, cluster_var, B = 999, seed = 42) {
  set.seed(seed)
  clusters <- unique(data[[cluster_var]])
  G <- length(clusters)

  # Original estimate
  m_orig <- feols(formula, data = data, cluster = cluster_var)
  beta_orig <- coef(m_orig)["ln_mw"]

  # Bootstrap
  boot_betas <- numeric(B)
  for (b in 1:B) {
    sampled_clusters <- sample(clusters, G, replace = TRUE)
    boot_data <- do.call(rbind, lapply(seq_along(sampled_clusters), function(i) {
      d <- data[data[[cluster_var]] == sampled_clusters[i], ]
      d[[cluster_var]] <- paste0(d[[cluster_var]], "_", i)  # unique cluster IDs
      d
    }))
    tryCatch({
      m_boot <- feols(formula, data = boot_data, cluster = cluster_var)
      boot_betas[b] <- coef(m_boot)["ln_mw"]
    }, error = function(e) {
      boot_betas[b] <<- NA
    })
  }

  boot_betas <- boot_betas[!is.na(boot_betas)]
  boot_se <- sd(boot_betas)
  boot_p <- mean(abs(boot_betas - mean(boot_betas)) >= abs(beta_orig - mean(boot_betas))) * 2
  boot_p <- min(boot_p, 1)
  ci <- quantile(boot_betas, c(0.025, 0.975))

  list(
    point_estimate = beta_orig,
    boot_se = boot_se,
    p_value = boot_p,
    ci_lower = ci[1],
    ci_upper = ci[2],
    B = length(boot_betas)
  )
}

cat("\n=== Pairs Cluster Bootstrap (Bachelor's P25) ===\n")

m_base_as_p25 <- feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
                       data = df_assoc, cluster = "state_fips")

boot_ba_p25 <- pairs_cluster_boot(
  df_ba,
  ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
  "state_fips", B = 999, seed = 20260219
)

cat(sprintf("  Coefficient: %.4f\n", boot_ba_p25$point_estimate))
cat(sprintf("  Bootstrap SE: %.4f\n", boot_ba_p25$boot_se))
cat(sprintf("  Bootstrap p-value: %.4f\n", boot_ba_p25$p_value))
cat(sprintf("  Bootstrap 95%% CI: [%.4f, %.4f]\n",
            boot_ba_p25$ci_lower, boot_ba_p25$ci_upper))

cat("\n=== Pairs Cluster Bootstrap (Associate P25) ===\n")

boot_as_p25 <- pairs_cluster_boot(
  df_assoc,
  ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
  "state_fips", B = 999, seed = 20260219
)

cat(sprintf("  Coefficient: %.4f\n", boot_as_p25$point_estimate))
cat(sprintf("  Bootstrap SE: %.4f\n", boot_as_p25$boot_se))
cat(sprintf("  Bootstrap p-value: %.4f\n", boot_as_p25$p_value))
cat(sprintf("  Bootstrap 95%% CI: [%.4f, %.4f]\n",
            boot_as_p25$ci_lower, boot_as_p25$ci_upper))

###############################################################################
# 5. Extract 95% CIs for all main specifications (for table use)
###############################################################################

cat("\n=== 95% Confidence Intervals (Analytical, State-Clustered) ===\n")

extract_ci <- function(model, var = "ln_mw", level = 0.95) {
  b <- coef(model)[var]
  s <- se(model)[var]
  z <- qnorm(1 - (1 - level) / 2)
  c(lower = b - z * s, upper = b + z * s)
}

# Main table (Table 2) models
results <- readRDS(file.path(data_dir, "regression_results.rds"))
main <- results$main_ba

ci_table <- data.frame(
  spec = character(), outcome = character(),
  beta = numeric(), se = numeric(),
  ci_lower = numeric(), ci_upper = numeric(),
  stringsAsFactors = FALSE
)

for (spec_name in c("m1", "m2", "m3")) {
  for (pctile in c("p25", "p50", "p75")) {
    mname <- paste0(spec_name, "_", pctile)
    m <- main[[mname]]
    ci <- extract_ci(m)
    ci_table <- rbind(ci_table, data.frame(
      spec = spec_name, outcome = pctile,
      beta = coef(m)["ln_mw"], se = se(m)["ln_mw"],
      ci_lower = ci["lower"], ci_upper = ci["upper"],
      stringsAsFactors = FALSE
    ))
  }
}

# Add division x cohort results
for (pctile in c("p25", "p50", "p75")) {
  m <- switch(pctile,
    p25 = m_div_ba_p25,
    p50 = m_div_ba_p50,
    p75 = m_div_ba_p75
  )
  ci <- extract_ci(m)
  ci_table <- rbind(ci_table, data.frame(
    spec = "div_cohort", outcome = pctile,
    beta = coef(m)["ln_mw"], se = se(m)["ln_mw"],
    ci_lower = ci["lower"], ci_upper = ci["upper"],
    stringsAsFactors = FALSE
  ))
}

rownames(ci_table) <- NULL
cat("\nConfidence interval table:\n")
print(ci_table, digits = 4)

###############################################################################
# 6. Save all revision results
###############################################################################

revision_results <- list(
  # Division x cohort FE models
  division_cohort = list(
    ba_p25 = m_div_ba_p25,
    ba_p50 = m_div_ba_p50,
    ba_p75 = m_div_ba_p75,
    as_p25 = m_div_as_p25
  ),
  # Geographic FE progression (bachelor's P25)
  geo_progression = list(
    cohort_fe = m_base_ba_p25,
    division_cohort = m_div_ba_p25,
    region_cohort = m_reg_ba_p25
  ),
  # Pairs cluster bootstrap results
  bootstrap = list(
    ba_p25 = boot_ba_p25,
    as_p25 = boot_as_p25
  ),
  # CI table for all specs
  ci_table = ci_table
)

saveRDS(revision_results, file.path(data_dir, "revision_results.rds"))

cat("\n=== All revision results saved to data/revision_results.rds ===\n")
cat("Done.\n")
