## ============================================================================
## 03_main_analysis.R — Primary DiD estimation
## Project: apep_0441 — State Bifurcation and Development in India
## ============================================================================

source("00_packages.R")
load("../data/analysis_panel.RData")

## ============================================================================
## 1. Descriptive statistics
## ============================================================================

cat("=== Summary Statistics ===\n")

# Baseline (1994-1999) means by treatment group
baseline <- panel_dmsp[year <= 1999, .(
  mean_nl = mean(nightlights, na.rm = TRUE),
  mean_log_nl = mean(log_nl, na.rm = TRUE),
  sd_nl = sd(nightlights, na.rm = TRUE),
  n_districts = uniqueN(dist_id)
), by = .(treated)]

print(baseline)

# By state pair
by_pair <- panel_dmsp[year <= 1999, .(
  mean_nl = mean(nightlights, na.rm = TRUE),
  n_districts = uniqueN(dist_id)
), by = .(state_pair, treated)]

cat("\nBaseline nightlights by state pair:\n")
print(by_pair[order(state_pair, treated)])

## ============================================================================
## 2. TWFE (benchmark — known to be biased with staggered treatment)
## ============================================================================

cat("\n=== TWFE Estimation (2000 cohort only, DMSP 1994-2013) ===\n")

# Restrict to 2000 cohort only
panel_2000 <- panel_dmsp[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")]

# Basic TWFE
twfe_basic <- feols(log_nl ~ treat_post | did + year,
                     data = panel_2000,
                     cluster = ~cluster_state)
cat("TWFE basic:\n")
print(summary(twfe_basic))

# TWFE with state-pair × year FE (absorb common shocks within pairs)
panel_2000[, pair_year := paste0(state_pair, "_", year)]
twfe_pair <- feols(log_nl ~ treat_post | did + pair_year,
                    data = panel_2000,
                    cluster = ~cluster_state)
cat("\nTWFE with pair×year FE:\n")
print(summary(twfe_pair))

## ============================================================================
## 3. Event study (TWFE)
## ============================================================================

cat("\n=== Event Study ===\n")

# Create event time
panel_2000[, event_time := year - 2001L]

# Event study with fixest::i()
es_twfe <- feols(log_nl ~ i(event_time, treated, ref = -1) | did + year,
                  data = panel_2000,
                  cluster = ~cluster_state)

cat("Event study coefficients:\n")
print(coeftable(es_twfe))

# Save event study coefficients for plotting
es_coefs <- as.data.table(coeftable(es_twfe), keep.rownames = TRUE)
setnames(es_coefs, c("term", "estimate", "se", "tstat", "pvalue"))
es_coefs[, event_time := as.integer(gsub("event_time::", "", gsub(":treated", "", term)))]
es_coefs <- es_coefs[!is.na(event_time)]

save(es_coefs, file = "../data/es_coefs.RData")

## ============================================================================
## 4. Callaway-Sant'Anna (heterogeneity-robust)
## ============================================================================

cat("\n=== Callaway-Sant'Anna Estimation ===\n")

# Prepare data for CS-DiD
# Need: panel with idname, tname, yname, gname
cs_data <- panel_dmsp[in_sample == 1L, .(
  id = did, year, log_nl, first_treat,
  cluster_state, treated, state_pair
)]

# Never-treated = control (first_treat == 0)
# Ensure balanced panel: keep only districts present in all years
year_counts <- cs_data[, .N, by = id]
balanced_ids <- year_counts[N == uniqueN(cs_data$year), id]
cs_balanced <- cs_data[id %in% balanced_ids]
cat("Balanced panel:", uniqueN(cs_balanced$id), "districts,",
    uniqueN(cs_balanced$year), "years\n")

cs_out <- tryCatch({
  att_gt(
    yname = "log_nl",
    tname = "year",
    idname = "id",
    gname = "first_treat",
    data = cs_balanced,
    control_group = "nevertreated",
    base_period = "universal",
    clustervars = "cluster_state",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("CS-DiD error:", conditionMessage(e), "\n")
  # Try with panel = FALSE for unbalanced
  att_gt(
    yname = "log_nl",
    tname = "year",
    idname = "id",
    gname = "first_treat",
    data = cs_data,
    control_group = "nevertreated",
    base_period = "universal",
    clustervars = "cluster_state",
    panel = FALSE,
    bstrap = TRUE,
    biters = 1000
  )
})

cat("CS-DiD group-time ATTs:\n")
print(summary(cs_out))

# Aggregate: simple ATT
cs_att <- aggte(cs_out, type = "simple")
cat("\nCS-DiD aggregate ATT:\n")
print(summary(cs_att))

# Aggregate: event study (dynamic)
cs_es <- aggte(cs_out, type = "dynamic")
cat("\nCS-DiD event study:\n")
print(summary(cs_es))

# Save CS results
save(cs_out, cs_att, cs_es, file = "../data/cs_results.RData")

## ============================================================================
## 5. Sun-Abraham estimator (via fixest)
## ============================================================================

cat("\n=== Sun-Abraham Estimation ===\n")

# Sun-Abraham via sunab()
# Use the full panel data (not cs_balanced which may be empty)
sa_data <- panel_dmsp[in_sample == 1L]
sa_out <- feols(log_nl ~ sunab(first_treat, year) | did + year,
                 data = sa_data,
                 cluster = ~cluster_state)

cat("Sun-Abraham:\n")
print(summary(sa_out))

save(sa_out, file = "../data/sa_results.RData")

## ============================================================================
## 6. By-pair heterogeneity
## ============================================================================

cat("\n=== Heterogeneity by State Pair ===\n")

pair_results <- list()
for (pair in c("UK-UP", "JH-BR", "CG-MP")) {
  sub <- panel_2000[state_pair == pair]
  fit <- feols(log_nl ~ treat_post | did + year,
               data = sub, cluster = ~cluster_state)
  pair_results[[pair]] <- fit
  cat(pair, ": coef =", coef(fit)["treat_post"],
      ", se =", se(fit)["treat_post"], "\n")
}

## ============================================================================
## 7. Capital city effects
## ============================================================================

cat("\n=== Capital vs Non-Capital Districts ===\n")

# Interact treatment with capital indicator
panel_2000[, capital_treat := is_capital * post_2000]
panel_2000[, noncapital_treat := (treated - is_capital) * post_2000]
# But we want: capital × post, noncapital_treated × post
panel_2000[, capital_post := is_capital * post_2000]
panel_2000[, treated_noncap := fifelse(treated == 1L & is_capital == 0L, 1L, 0L)]
panel_2000[, treated_noncap_post := treated_noncap * post_2000]

capital_het <- feols(log_nl ~ capital_post + treated_noncap_post | did + year,
                      data = panel_2000, cluster = ~cluster_state)
cat("Capital city heterogeneity:\n")
print(summary(capital_het))

## ============================================================================
## 8. Wild cluster bootstrap
## ============================================================================

cat("\n=== Wild Cluster Bootstrap (Manual Implementation) ===\n")

# Manual wild cluster bootstrap (Cameron, Gelbach, Miller 2008)
# With only 6 state clusters, enumerate all 2^6 = 64 Rademacher sign combinations
wild_cluster_bootstrap <- function(model, data, cluster_var, param, n_boot = 999) {
  # Get cluster IDs
  clusters <- unique(data[[cluster_var]])
  G <- length(clusters)

  # Restricted model (impose null: param = 0)
  fml_restricted <- update(formula(model), . ~ . - treat_post)
  # Simpler: run model, get residuals under null
  data_null <- copy(data)
  data_null[, treat_post := 0]
  restricted <- feols(log_nl ~ 1 | did + year, data = data, cluster = as.formula(paste0("~", cluster_var)))
  resid_r <- residuals(restricted)

  # Original t-statistic
  orig_coef <- coef(model)[param]
  orig_se <- se(model)[param]
  orig_t <- orig_coef / orig_se

  # Bootstrap
  boot_t <- numeric(n_boot)
  for (b in 1:n_boot) {
    # Rademacher weights by cluster
    weights <- sample(c(-1, 1), G, replace = TRUE)
    names(weights) <- clusters
    data[, boot_resid := resid_r * weights[as.character(get(cluster_var))]]
    data[, boot_y := fitted(restricted) + boot_resid]

    boot_fit <- tryCatch({
      feols(boot_y ~ treat_post | did + year, data = data,
            cluster = as.formula(paste0("~", cluster_var)))
    }, error = function(e) NULL)

    if (!is.null(boot_fit)) {
      boot_t[b] <- coef(boot_fit)[param] / se(boot_fit)[param]
    } else {
      boot_t[b] <- NA
    }
  }

  # Two-sided p-value
  p_val <- mean(abs(boot_t) >= abs(orig_t), na.rm = TRUE)
  list(p_val = p_val, orig_t = orig_t, boot_t = boot_t[!is.na(boot_t)])
}

boot_result <- tryCatch({
  wild_cluster_bootstrap(twfe_basic, panel_2000, "cluster_state", "treat_post", n_boot = 999)
}, error = function(e) {
  cat("Bootstrap error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(boot_result)) {
  cat("Wild bootstrap p-value:", boot_result$p_val, "\n")
  cat("Original t-stat:", boot_result$orig_t, "\n")
}

## ============================================================================
## 9. Save all results
## ============================================================================

save(twfe_basic, twfe_pair, es_twfe, pair_results, capital_het,
     boot_result, panel_2000,
     file = "../data/main_results.RData")

cat("\n=== Main analysis complete ===\n")
