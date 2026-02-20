# =============================================================================
# 04_robustness.R — Robustness Checks
# apep_0427: France Apprenticeship Subsidy and Entry-Level Labor Markets
# =============================================================================

source("00_packages.R")

cat("=== Running robustness checks for apep_0427 ===\n")

sector_panel   <- readRDS("../data/sector_panel.rds")
cross_country  <- readRDS("../data/cross_country_panel.rds")

# =============================================================
# 1. Event Study: Sector-Exposure Bartik
# =============================================================
cat("\n--- Robustness 1: Event Study (Sector Exposure) ---\n")

# Create event-time dummies relative to 2023Q1
sector_es <- sector_panel %>%
  mutate(
    event_time = (yq - 2023.0) * 4,  # quarters relative to Jan 2023
    event_time = round(event_time)  # integer quarters
  ) %>%
  filter(event_time >= -20 & event_time <= 10)

# Interaction with exposure for each event time
# Using fixest sunab-style: exposure x event_time dummies
es_model <- feols(
  youth_share ~ i(event_time, exposure, ref = -1) | sector + yq,
  data = sector_es,
  cluster = ~sector
)
cat("Event study model (sector exposure):\n")
summary(es_model)

saveRDS(es_model, "../data/event_study_sector.rds")

# =============================================================
# 2. Placebo Test: Prime-Age Workers (25-54)
# =============================================================
cat("\n--- Robustness 2: Placebo (Prime-Age Workers) ---\n")

# Prime-age employment should not respond to apprenticeship subsidy changes
sector_prime <- sector_panel %>%
  mutate(prime_share = ifelse(!is.na(emp_total) & emp_total > 0,
                              emp_prime / emp_total * 100, NA))

m_placebo <- feols(
  prime_share ~ bartik_reduction | sector + yq,
  data = sector_prime,
  cluster = ~sector
)
cat("Placebo (prime-age share):\n")
summary(m_placebo)

saveRDS(m_placebo, "../data/placebo_prime_age.rds")

# =============================================================
# 3. Leave-One-Sector-Out
# =============================================================
cat("\n--- Robustness 3: Leave-One-Sector-Out ---\n")

sectors <- unique(sector_panel$sector)
loso_results <- map_dfr(sectors, function(s) {
  d <- sector_panel %>% filter(sector != s)
  m <- tryCatch({
    feols(youth_share ~ bartik_reduction | sector + yq,
          data = d, cluster = ~sector)
  }, error = function(e) return(NULL))
  if (is.null(m)) return(NULL)
  tibble(
    excluded_sector = s,
    coef = coef(m)["bartik_reduction"],
    se = se(m)["bartik_reduction"],
    n = nobs(m)
  )
})

cat("Leave-one-sector-out results:\n")
print(loso_results)

saveRDS(loso_results, "../data/loso_results.rds")

# =============================================================
# 4. Permutation Inference (Randomization Inference)
# =============================================================
cat("\n--- Robustness 4: Permutation Inference ---\n")

set.seed(42)
n_perms <- 1000

# Observed test statistic
obs_stat <- coef(feols(
  youth_share ~ bartik_reduction | sector + yq,
  data = sector_panel, cluster = ~sector
))["bartik_reduction"]

# Permute sector exposure assignment AT THE SECTOR LEVEL
# Create sector-to-exposure mapping, then permute the mapping
sector_exposure_map <- sector_panel %>%
  distinct(sector, exposure)

perm_stats <- replicate(n_perms, {
  # Permute exposure across sectors (preserving within-sector structure)
  perm_map <- sector_exposure_map %>%
    mutate(perm_exposure = sample(exposure))
  perm_data <- sector_panel %>%
    left_join(perm_map %>% select(sector, perm_exposure), by = "sector") %>%
    mutate(perm_bartik = perm_exposure * post_reduction)
  m <- tryCatch({
    coef(feols(
      youth_share ~ perm_bartik | sector + yq,
      data = perm_data, cluster = ~sector
    ))["perm_bartik"]
  }, error = function(e) NA_real_)
  return(m)
})

perm_stats <- na.omit(perm_stats)
ri_p <- mean(abs(perm_stats) >= abs(obs_stat))

cat(sprintf("Observed statistic: %.4f\n", obs_stat))
cat(sprintf("RI p-value (two-sided): %.4f (based on %d permutations)\n",
            ri_p, length(perm_stats)))

saveRDS(list(obs = obs_stat, perms = perm_stats, p = ri_p),
        "../data/permutation_inference.rds")

# =============================================================
# 5. Cross-Country Event Study
# =============================================================
cat("\n--- Robustness 5: Cross-Country Event Study ---\n")

cc_youth <- cross_country %>%
  filter(age_group == "Y15-24") %>%
  mutate(
    event_time = (yq - 2023.0) * 4,
    event_time = round(event_time)
  ) %>%
  filter(event_time >= -20 & event_time <= 10)

es_cc <- feols(
  emp_rate ~ i(event_time, france, ref = -1) | country + yq,
  data = cc_youth,
  cluster = ~country
)
cat("Cross-country event study:\n")
summary(es_cc)

saveRDS(es_cc, "../data/event_study_cross_country.rds")

# =============================================================
# 6. Pre-Trend Formal Tests
# =============================================================
cat("\n--- Robustness 6: Pre-Trend Tests ---\n")

# Test if pre-trend coefficients are jointly zero
pre_coefs <- coeftable(es_model) %>%
  as.data.frame() %>%
  rownames_to_column("term") %>%
  filter(grepl("event_time::", term)) %>%
  mutate(
    et = as.numeric(gsub(".*::(-?\\d+):.*", "\\1", term))
  ) %>%
  filter(et < 0, et != -1)

cat(sprintf("Number of pre-period coefficients: %d\n", nrow(pre_coefs)))
if (nrow(pre_coefs) > 0) {
  cat(sprintf("Max absolute pre-period coefficient: %.4f\n",
              max(abs(pre_coefs$Estimate), na.rm = TRUE)))
}

# Wald test for joint significance of pre-period
tryCatch({
  wald_pre <- wald(es_model, paste0("event_time::", pre_coefs$et, ":exposure"))
  cat("Wald test for pre-trends:\n")
  print(wald_pre)
}, error = function(e) {
  cat("Wald test could not be computed (likely too few clusters).\n")
})

# =============================================================
# 7. Alternative Control Groups
# =============================================================
cat("\n--- Robustness 7: Alternative Control Groups ---\n")

# Exclude Germany (has its own strong apprenticeship system)
cc_no_de <- cross_country %>%
  filter(age_group == "Y15-24", country != "DE")

m_no_de <- feols(
  emp_rate ~ france:post_reduction | country + yq,
  data = cc_no_de,
  cluster = ~country
)
cat("Excluding Germany:\n")
summary(m_no_de)

# Only Southern European controls (Spain, Italy, Portugal)
cc_south <- cross_country %>%
  filter(age_group == "Y15-24", country %in% c("FR", "ES", "IT", "PT"))

m_south <- feols(
  emp_rate ~ france:post_reduction | country + yq,
  data = cc_south,
  cluster = ~country
)
cat("Southern European controls only:\n")
summary(m_south)

# Only neighboring countries (Belgium, Germany, Netherlands)
cc_neighbor <- cross_country %>%
  filter(age_group == "Y15-24", country %in% c("FR", "BE", "DE", "NL"))

m_neighbor <- feols(
  emp_rate ~ france:post_reduction | country + yq,
  data = cc_neighbor,
  cluster = ~country
)
cat("Neighboring controls only:\n")
summary(m_neighbor)

robustness_cc <- list(
  no_germany = m_no_de,
  southern_only = m_south,
  neighbors_only = m_neighbor
)

saveRDS(robustness_cc, "../data/robustness_control_groups.rds")

# =============================================================
# 8. Dose-Response: Continuous Exposure
# =============================================================
cat("\n--- Robustness 8: Dose-Response ---\n")

# Quintiles of exposure
sector_panel_q <- sector_panel %>%
  mutate(exposure_quintile = ntile(exposure, 5))

m_dose <- feols(
  youth_share ~ i(exposure_quintile, post_reduction, ref = 1) | sector + yq,
  data = sector_panel_q,
  cluster = ~sector
)
cat("Dose-response (quintiles):\n")
summary(m_dose)

saveRDS(m_dose, "../data/dose_response.rds")

# =============================================================
# 9. Wild Cluster Bootstrap (WCB) — Rademacher weights
#    Manual implementation (fwildclusterboot not available for R 4.3)
# =============================================================
cat("\n--- Robustness 9: Wild Cluster Bootstrap ---\n")

set.seed(42)
n_boot <- 999

# Generic WCB function: restricted wild cluster bootstrap
# Imposes H0: coef = 0 using restricted model residuals
# Uses Rademacher weights (+1/-1) at the cluster level
# Following Cameron, Gelbach, Miller (2008)
run_wcb <- function(data, formula_str, coef_name, cluster_var, B = 999) {
  clust_form <- as.formula(paste0("~", cluster_var))

  # Full model (for observed test statistic)
  full_model <- feols(as.formula(formula_str), data = data, cluster = clust_form)
  obs_t <- coef(full_model)[coef_name] / se(full_model)[coef_name]

  # Restricted model (imposing H0: coef_name = 0)
  # Parse formula to remove the coefficient of interest
  # formula_str is like "y ~ x | fe1 + fe2"
  parts <- strsplit(formula_str, "\\|")[[1]]
  lhs_rhs <- strsplit(trimws(parts[1]), "~")[[1]]
  y_var <- trimws(lhs_rhs[1])
  fe_part <- if (length(parts) > 1) trimws(parts[2]) else NULL

  # Restricted: y ~ 1 | FE (drop the treatment variable)
  if (!is.null(fe_part)) {
    restricted_formula <- as.formula(paste(y_var, "~ 1 |", fe_part))
  } else {
    restricted_formula <- as.formula(paste(y_var, "~ 1"))
  }

  restricted_model <- feols(restricted_formula, data = data, cluster = clust_form)
  restricted_fitted <- fitted(restricted_model)
  restricted_resids <- residuals(restricted_model)

  # Get cluster IDs
  clusters <- unique(data[[cluster_var]])
  G <- length(clusters)

  boot_t <- replicate(B, {
    # Rademacher weights: +1 or -1 per cluster
    weights <- sample(c(-1, 1), G, replace = TRUE)
    names(weights) <- clusters
    w_vec <- weights[as.character(data[[cluster_var]])]

    # Bootstrap DGP under H0: y* = fitted_restricted + restricted_resid * weight
    data$y_boot <- restricted_fitted + restricted_resids * w_vec

    # Re-estimate FULL model on bootstrap data
    boot_form <- as.formula(gsub("^[^~]+", "y_boot", formula_str))
    m_boot <- tryCatch({
      feols(boot_form, data = data, cluster = clust_form)
    }, error = function(e) NULL)

    if (is.null(m_boot)) return(NA_real_)
    coef(m_boot)[coef_name] / se(m_boot)[coef_name]
  })

  boot_t <- na.omit(boot_t)
  p_val <- mean(abs(boot_t) >= abs(obs_t))
  return(list(obs_t = obs_t, boot_t = boot_t, p_val = p_val, n_boot = length(boot_t)))
}

# Main: youth share
cat("  WCB for main exposure DiD (youth share)...\n")
sp_clean <- sector_panel %>% filter(!is.na(youth_share))
wcb_main <- tryCatch({
  run_wcb(sp_clean, "youth_share ~ bartik_reduction | sector + yq",
          "bartik_reduction", "sector", n_boot)
}, error = function(e) { cat(sprintf("  Failed: %s\n", e$message)); list(p_val = NA) })
cat(sprintf("  WCB main p-value: %.4f\n", wcb_main$p_val))

# Youth employment level
cat("  WCB for youth employment level...\n")
sp_level <- sector_panel %>% filter(!is.na(emp_youth))
wcb_level <- tryCatch({
  run_wcb(sp_level, "emp_youth ~ bartik_reduction | sector + yq",
          "bartik_reduction", "sector", n_boot)
}, error = function(e) { cat(sprintf("  Failed: %s\n", e$message)); list(p_val = NA) })
cat(sprintf("  WCB level p-value: %.4f\n", wcb_level$p_val))

# Total employment placebo
cat("  WCB for total employment placebo...\n")
wcb_total <- tryCatch({
  run_wcb(sp_clean, "emp_total ~ bartik_reduction | sector + yq",
          "bartik_reduction", "sector", n_boot)
}, error = function(e) { cat(sprintf("  Failed: %s\n", e$message)); list(p_val = NA) })
cat(sprintf("  WCB total p-value: %.4f\n", wcb_total$p_val))

# Cross-country DiD
cat("  WCB for cross-country DiD...\n")
cc_youth_wcb <- cross_country %>%
  filter(age_group == "Y15-24") %>%
  mutate(fr_post = france * post_reduction)
wcb_cc <- tryCatch({
  run_wcb(cc_youth_wcb, "emp_rate ~ fr_post | country + yq",
          "fr_post", "country", n_boot)
}, error = function(e) { cat(sprintf("  Failed: %s\n", e$message)); list(p_val = NA) })
cat(sprintf("  WCB cross-country p-value: %.4f\n", wcb_cc$p_val))

wcb_results <- list(
  main = wcb_main,
  level = wcb_level,
  total = wcb_total,
  cross_country = wcb_cc
)

saveRDS(wcb_results, "../data/wcb_results.rds")

# =============================================================
# 10. Balance Test: Exposure vs Pre-2023 Sector Growth
# =============================================================
cat("\n--- Robustness 10: Balance Test ---\n")

# Test: is sector exposure correlated with pre-2023 sector growth trends?
pre_trends <- sector_panel %>%
  filter(yq < 2023.0, !is.na(youth_share)) %>%
  group_by(sector, exposure) %>%
  summarize(
    mean_youth_share = mean(youth_share, na.rm = TRUE),
    growth_youth_share = ifelse(n() > 4,
      coef(lm(youth_share ~ yq))[2], NA_real_),
    .groups = "drop"
  )

balance_test <- cor.test(pre_trends$exposure, pre_trends$growth_youth_share,
                          use = "complete.obs")
cat(sprintf("  Balance test: correlation = %.4f, p = %.4f\n",
            balance_test$estimate, balance_test$p.value))

saveRDS(list(pre_trends = pre_trends, balance_test = balance_test),
        "../data/balance_test.rds")

# =============================================================
# 11. Pre-2025 Sample (Exclude February 2025 Reform)
# =============================================================
cat("\n--- Robustness 11: Pre-2025 Sample ---\n")

# Truncate at 2024Q4 to exclude the February 2025 redesign
sp_pre2025 <- sector_panel %>% filter(yq < 2025.0)

m_pre2025_share <- feols(
  youth_share ~ bartik_reduction | sector + yq,
  data = sp_pre2025 %>% filter(!is.na(youth_share)),
  cluster = ~sector
)
cat("Pre-2025 youth share:\n")
summary(m_pre2025_share)

m_pre2025_level <- feols(
  emp_youth ~ bartik_reduction | sector + yq,
  data = sp_pre2025 %>% filter(!is.na(emp_youth)),
  cluster = ~sector
)
cat("\nPre-2025 youth level:\n")
summary(m_pre2025_level)

m_pre2025_total <- feols(
  emp_total ~ bartik_reduction | sector + yq,
  data = sp_pre2025 %>% filter(!is.na(youth_share)),
  cluster = ~sector
)
cat("\nPre-2025 total employment:\n")
summary(m_pre2025_total)

pre2025_results <- list(
  share = m_pre2025_share,
  level = m_pre2025_level,
  total = m_pre2025_total
)
saveRDS(pre2025_results, "../data/pre2025_results.rds")

# =============================================================
# 12. Sector-Specific Linear Trends
# =============================================================
cat("\n--- Robustness 12: Sector-Specific Linear Trends ---\n")

# Address the sectoral demand confound: add sector-specific linear time trends
# This absorbs differential pre-existing growth trajectories across sectors
sp_trends <- sector_panel %>%
  filter(!is.na(youth_share)) %>%
  mutate(time_trend = as.numeric(yq - 2015.0))

m_trends_share <- feols(
  youth_share ~ bartik_reduction | sector[time_trend] + yq,
  data = sp_trends,
  cluster = ~sector
)
cat("With sector-specific linear trends (youth share):\n")
summary(m_trends_share)

m_trends_level <- feols(
  emp_youth ~ bartik_reduction | sector[time_trend] + yq,
  data = sp_trends %>% filter(!is.na(emp_youth)),
  cluster = ~sector
)
cat("\nWith sector-specific linear trends (youth level):\n")
summary(m_trends_level)

m_trends_total <- feols(
  emp_total ~ bartik_reduction | sector[time_trend] + yq,
  data = sp_trends,
  cluster = ~sector
)
cat("\nWith sector-specific linear trends (total employment):\n")
summary(m_trends_total)

trends_results <- list(
  share = m_trends_share,
  level = m_trends_level,
  total = m_trends_total
)
saveRDS(trends_results, "../data/sector_trends_results.rds")

cat("\n=== Robustness checks complete ===\n")
