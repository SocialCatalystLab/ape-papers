## 04_robustness.R — Robustness checks
## Paper 110: Recreational Marijuana and Business Formation

source("00_packages.R")

# ──────────────────────────────────────────────────────────────
# 1. Load data and main results
# ──────────────────────────────────────────────────────────────
cat("Loading analysis datasets...\n")
state_year <- read_csv(file.path(DATA_DIR, "panel_state_year.csv"), show_col_types = FALSE) %>%
  mutate(state_id = as.integer(factor(state_abbr)))

state_year_hba <- read_csv(file.path(DATA_DIR, "panel_state_year_hba.csv"), show_col_types = FALSE) %>%
  mutate(state_id = as.integer(factor(state_abbr)))
state_year_wba <- read_csv(file.path(DATA_DIR, "panel_state_year_wba.csv"), show_col_types = FALSE) %>%
  mutate(state_id = as.integer(factor(state_abbr)))

# ──────────────────────────────────────────────────────────────
# 2. High-propensity business applications (HBA)
# ──────────────────────────────────────────────────────────────
cat("\n=== CS with High-Propensity BA ===\n")

cs_hba <- att_gt(
  yname = "log_apps_pc",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = state_year_hba,
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal"
)
cs_hba_agg <- aggte(cs_hba, type = "simple")
cat("CS HBA ATT:", round(cs_hba_agg$overall.att, 4),
    "SE:", round(cs_hba_agg$overall.se, 4), "\n")

cs_hba_es <- aggte(cs_hba, type = "dynamic", min_e = -7, max_e = 7)

# ──────────────────────────────────────────────────────────────
# 3. Applications with planned wages (WBA)
# ──────────────────────────────────────────────────────────────
cat("\n=== CS with Wage-Planned BA ===\n")

cs_wba <- att_gt(
  yname = "log_apps_pc",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = state_year_wba,
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal"
)
cs_wba_agg <- aggte(cs_wba, type = "simple")
cat("CS WBA ATT:", round(cs_wba_agg$overall.att, 4),
    "SE:", round(cs_wba_agg$overall.se, 4), "\n")

# ──────────────────────────────────────────────────────────────
# 4. Restrict comparison to medical-marijuana-only states
# ──────────────────────────────────────────────────────────────
cat("\n=== CS with Medical-Only Control Group ===\n")

# States that have medical MJ but never legalized recreational
medical_only <- state_year %>%
  group_by(state_abbr) %>%
  summarise(
    has_medical_ever = max(has_medical),
    ever_treated = max(ever_treated)
  ) %>%
  filter(has_medical_ever == 1)

# Filter to treated states + medical-only control states
sy_medical <- state_year %>%
  filter(state_abbr %in% medical_only$state_abbr) %>%
  mutate(state_id = as.integer(factor(state_abbr)))

cs_medical <- att_gt(
  yname = "log_apps_pc",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = sy_medical,
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal"
)
cs_medical_agg <- aggte(cs_medical, type = "simple")
cat("CS (medical-only control) ATT:", round(cs_medical_agg$overall.att, 4),
    "SE:", round(cs_medical_agg$overall.se, 4), "\n")

# ──────────────────────────────────────────────────────────────
# 5. Exclude COVID years (2020-2021)
# ──────────────────────────────────────────────────────────────
cat("\n=== CS Excluding COVID Years ===\n")

sy_nocovid <- state_year %>%
  filter(!(year %in% c(2020, 2021))) %>%
  mutate(state_id = as.integer(factor(state_abbr)))

cs_nocovid <- att_gt(
  yname = "log_apps_pc",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = sy_nocovid,
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal"
)
cs_nocovid_agg <- aggte(cs_nocovid, type = "simple")
cat("CS (no COVID) ATT:", round(cs_nocovid_agg$overall.att, 4),
    "SE:", round(cs_nocovid_agg$overall.se, 4), "\n")

# ──────────────────────────────────────────────────────────────
# 6. Randomization Inference
# ──────────────────────────────────────────────────────────────
cat("\n=== Randomization Inference ===\n")

# Observed TWFE coefficient
twfe_main <- feols(
  log_apps_pc ~ treated | state_abbr + year,
  data = state_year,
  cluster = ~state_abbr
)
obs_coef <- coef(twfe_main)["treated"]

# Permutation test: reassign treatment to random states
set.seed(42)
n_perms <- 999
perm_coefs <- numeric(n_perms)

# Get treated states and their timing
treated_states <- state_year %>%
  filter(first_treat > 0) %>%
  distinct(state_abbr, first_treat)
n_treated <- nrow(treated_states)
all_states <- unique(state_year$state_abbr)

for (p in seq_len(n_perms)) {
  # Randomly assign treatment to same number of states
  perm_states <- sample(all_states, n_treated)
  # Assign same cohort distribution
  perm_timing <- tibble(
    state_abbr = perm_states,
    perm_first_treat = sample(treated_states$first_treat)
  )

  perm_data <- state_year %>%
    select(-treated, -first_treat, -ever_treated) %>%
    left_join(perm_timing, by = "state_abbr") %>%
    mutate(
      perm_first_treat = if_else(is.na(perm_first_treat), 0L, perm_first_treat),
      treated_perm = if_else(perm_first_treat > 0 & year >= perm_first_treat, 1L, 0L)
    )

  perm_fit <- tryCatch(
    feols(log_apps_pc ~ treated_perm | state_abbr + year, data = perm_data, warn = FALSE),
    error = function(e) NULL
  )
  if (!is.null(perm_fit)) {
    perm_coefs[p] <- coef(perm_fit)["treated_perm"]
  } else {
    perm_coefs[p] <- NA
  }

  if (p %% 100 == 0) cat("  Permutation", p, "/", n_perms, "\n")
}

perm_coefs <- perm_coefs[!is.na(perm_coefs)]
ri_pvalue <- mean(abs(perm_coefs) >= abs(obs_coef))
cat("RI p-value (two-sided):", round(ri_pvalue, 4), "\n")
cat("Observed coef:", round(obs_coef, 4), "\n")
cat("Permutation distribution: mean =", round(mean(perm_coefs), 4),
    "sd =", round(sd(perm_coefs), 4), "\n")

# ──────────────────────────────────────────────────────────────
# 7. Pairs Cluster Bootstrap (manual)
# ──────────────────────────────────────────────────────────────
cat("\n=== Pairs Cluster Bootstrap ===\n")

set.seed(123)
n_boot <- 999
boot_coefs <- numeric(n_boot)
states_list <- unique(state_year$state_abbr)
n_states <- length(states_list)

for (b in seq_len(n_boot)) {
  # Resample states with replacement
  boot_states <- sample(states_list, n_states, replace = TRUE)
  # Build bootstrap dataset (handle duplicates)
  boot_data <- map_dfr(seq_along(boot_states), function(i) {
    state_year %>%
      filter(state_abbr == boot_states[i]) %>%
      mutate(boot_state_id = i)
  })
  boot_fit <- tryCatch(
    feols(log_apps_pc ~ treated | boot_state_id + year, data = boot_data, warn = FALSE),
    error = function(e) NULL
  )
  if (!is.null(boot_fit)) {
    boot_coefs[b] <- coef(boot_fit)["treated"]
  } else {
    boot_coefs[b] <- NA
  }
  if (b %% 200 == 0) cat("  Bootstrap", b, "/", n_boot, "\n")
}

boot_coefs <- boot_coefs[!is.na(boot_coefs)]
boot_se <- sd(boot_coefs)
boot_ci <- quantile(boot_coefs, c(0.025, 0.975))
boot_pval <- 2 * min(mean(boot_coefs >= 0), mean(boot_coefs <= 0))

cat("Pairs bootstrap SE:", round(boot_se, 4), "\n")
cat("Pairs bootstrap 95% CI: [", round(boot_ci[1], 4), ",",
    round(boot_ci[2], 4), "]\n")
cat("Pairs bootstrap p-value:", round(boot_pval, 4), "\n")

wcb <- list(p_val = boot_pval, conf_int = as.numeric(boot_ci),
            se = boot_se, boot_coefs = boot_coefs)

# ──────────────────────────────────────────────────────────────
# 8. Heterogeneity: Early vs Late Adopters
# ──────────────────────────────────────────────────────────────
cat("\n=== Heterogeneity: Early vs Late Adopters ===\n")

# Early adopters: first_treat <= 2017 (CO, WA, OR, AK, NV)
# Late adopters: first_treat > 2017
state_year_het <- state_year %>%
  mutate(
    early_adopter = if_else(first_treat > 0 & first_treat <= 2017, 1L, 0L),
    late_adopter = if_else(first_treat > 2017, 1L, 0L),
    treated_early = treated * early_adopter,
    treated_late = treated * late_adopter
  )

het_timing <- feols(
  log_apps_pc ~ treated_early + treated_late | state_abbr + year,
  data = state_year_het,
  cluster = ~state_abbr
)
cat("Early adopter ATT:", round(coef(het_timing)["treated_early"], 4),
    "SE:", round(se(het_timing)["treated_early"], 4), "\n")
cat("Late adopter ATT:", round(coef(het_timing)["treated_late"], 4),
    "SE:", round(se(het_timing)["treated_late"], 4), "\n")

# ──────────────────────────────────────────────────────────────
# 9. BFS Series Decomposition (CS estimates)
# ──────────────────────────────────────────────────────────────
cat("\n=== CS by BFS Series Type ===\n")

# CS for CBA (corporate business applications)
state_year_cba <- read_csv(file.path(DATA_DIR, "panel_state_year_cba.csv"), show_col_types = FALSE) %>%
  mutate(state_id = as.integer(factor(state_abbr)))

cs_cba <- tryCatch({
  att_gt(
    yname = "log_apps_pc",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = state_year_cba,
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal"
  ) %>% aggte(type = "simple")
}, error = function(e) { cat("CS CBA failed:", e$message, "\n"); NULL })

if (!is.null(cs_cba)) {
  cat("CS CBA ATT:", round(cs_cba$overall.att, 4),
      "SE:", round(cs_cba$overall.se, 4), "\n")
}

# CS for BF8Q (actual business formations)
state_year_bf <- read_csv(file.path(DATA_DIR, "panel_state_year_bf.csv"), show_col_types = FALSE) %>%
  mutate(state_id = as.integer(factor(state_abbr))) %>%
  filter(!is.na(log_apps_pc) & is.finite(log_apps_pc))

cs_bf <- tryCatch({
  att_gt(
    yname = "log_apps_pc",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = state_year_bf,
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal"
  ) %>% aggte(type = "simple")
}, error = function(e) { cat("CS BF8Q failed:", e$message, "\n"); NULL })

# ──────────────────────────────────────────────────────────────
# 10. Border-State Exclusion Robustness
# ──────────────────────────────────────────────────────────────
cat("\n=== Border-State Exclusion ===\n")

# Define states that do NOT border any of the 21 treated states
# Treated: CO, WA, OR, AK, NV, CA, MA, ME, MI, IL, AZ, MT, NJ, NM, NY, RI, VT, CT, MO, MD, OH
# Interior never-treated states (no border with any treated state):
# AL, FL, GA, HI, LA, MN, MS, NC, SC
interior_controls <- c("AL", "FL", "GA", "HI", "LA", "MN", "MS", "NC", "SC")

treated_states_abbr <- state_year %>%
  filter(first_treat > 0) %>%
  distinct(state_abbr) %>%
  pull(state_abbr)

sy_interior <- state_year %>%
  filter(state_abbr %in% c(treated_states_abbr, interior_controls)) %>%
  mutate(state_id = as.integer(factor(state_abbr)))

n_interior <- nrow(sy_interior)
n_interior_units <- n_distinct(sy_interior$state_abbr)
n_interior_treated <- sum(unique(sy_interior$state_abbr) %in% treated_states_abbr)
n_interior_control <- n_interior_units - n_interior_treated

cat("Interior control states:", paste(interior_controls, collapse = ", "), "\n")
cat("N obs:", n_interior, " N units:", n_interior_units,
    " (", n_interior_treated, " treated,", n_interior_control, " controls)\n")

cs_interior <- tryCatch({
  att_gt(
    yname = "log_apps_pc",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = sy_interior,
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal"
  ) %>% aggte(type = "simple")
}, error = function(e) { cat("CS interior failed:", e$message, "\n"); NULL })

if (!is.null(cs_interior)) {
  cat("CS (interior controls) ATT:", round(cs_interior$overall.att, 4),
      "SE:", round(cs_interior$overall.se, 4), "\n")
}

# Also TWFE version
twfe_interior <- feols(
  log_apps_pc ~ treated | state_abbr + year,
  data = sy_interior,
  cluster = ~state_abbr
)
cat("TWFE (interior controls): beta =", round(coef(twfe_interior)["treated"], 4),
    "SE =", round(se(twfe_interior)["treated"], 4), "\n")

# ──────────────────────────────────────────────────────────────
# 11. Wild Cluster Bootstrap (if fwildclusterboot available)
# ──────────────────────────────────────────────────────────────
cat("\n=== Wild Cluster Bootstrap ===\n")

wcb_result <- NULL
tryCatch({
  if (!require(fwildclusterboot, quietly = TRUE)) {
    install.packages("fwildclusterboot", repos = "https://cran.r-project.org", quiet = TRUE)
    library(fwildclusterboot)
  }
  # Need lm/felm model for boottest - use lm with dummies
  # fwildclusterboot works with fixest models
  wcb_boot <- boottest(
    twfe_main,
    param = "treated",
    B = 999,
    clustid = "state_abbr",
    type = "rademacher"
  )
  wcb_result <- list(
    p_val = pval(wcb_boot),
    ci = wcb_boot$conf_int,
    t_stat = teststat(wcb_boot)
  )
  cat("WCB p-value:", round(wcb_result$p_val, 4), "\n")
  cat("WCB 95% CI: [", round(wcb_result$ci[1], 4), ",", round(wcb_result$ci[2], 4), "]\n")
}, error = function(e) {
  cat("Wild cluster bootstrap failed:", e$message, "\n")
  cat("Continuing without WCB results.\n")
})

# ──────────────────────────────────────────────────────────────
# 12. Save robustness results
# ──────────────────────────────────────────────────────────────
cat("\nSaving robustness results...\n")

saveRDS(list(
  cs_hba = cs_hba_agg,
  cs_wba = cs_wba_agg,
  cs_medical = cs_medical_agg,
  cs_nocovid = cs_nocovid_agg,
  ri_pvalue = ri_pvalue,
  obs_coef = obs_coef,
  perm_coefs = perm_coefs,
  wcb = wcb,
  cs_hba_es = cs_hba_es,
  het_timing = het_timing,
  cs_cba = cs_cba,
  cs_bf = cs_bf,
  cs_interior = cs_interior,
  twfe_interior = twfe_interior,
  n_interior = n_interior,
  n_interior_units = n_interior_units,
  n_interior_control = n_interior_control,
  wcb_result = wcb_result
), file.path(DATA_DIR, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
