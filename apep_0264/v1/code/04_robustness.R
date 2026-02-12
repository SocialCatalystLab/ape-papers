## 04_robustness.R — Robustness checks
## Paper: "The Quiet Life Goes Macro" (apep_0243)

source("00_packages.R")

cat("=== ROBUSTNESS CHECKS ===\n")

panel <- readRDS("../data/analysis_panel.rds")

# ============================================================
# 1. DROP LOBBYING STATES
# States where specific firm lobbying documented:
#   Indiana (Cummins Engine), Pennsylvania (several firms),
#   Delaware (business community), New York (major firms)
# ============================================================

cat("\n--- 1. Drop Lobbying States ---\n")

lobbying_states <- c("18", "42", "10", "36")  # IN, PA, DE, NY

panel_no_lobby <- panel %>%
  filter(!(state_fips %in% lobbying_states)) %>%
  # Re-index state_id
  mutate(state_id = as.integer(factor(state_fips)))

panel_no_lobby_cs <- panel_no_lobby %>%
  filter(year >= 1988, year <= 2019, !is.na(avg_estab_size)) %>%
  mutate(log_avg_size = log(avg_estab_size))

cs_no_lobby <- att_gt(
  yname = "log_avg_size",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = panel_no_lobby_cs,
  control_group = "nevertreated",
  base_period = "universal",
  print_details = FALSE
)

att_no_lobby <- aggte(cs_no_lobby, type = "simple")
es_no_lobby <- aggte(cs_no_lobby, type = "dynamic", min_e = -10, max_e = 20)

cat(sprintf("Drop lobbying states — ATT: %.4f (SE: %.4f)\n",
            att_no_lobby$overall.att, att_no_lobby$overall.se))

saveRDS(att_no_lobby, "../data/rob_att_no_lobby.rds")
saveRDS(es_no_lobby, "../data/rob_es_no_lobby.rds")

# ============================================================
# 2. NOT-YET-TREATED AS CONTROL GROUP
# ============================================================

cat("\n--- 2. Not-yet-treated controls ---\n")

panel_nyt <- panel %>%
  filter(year >= 1988, year <= 2019, !is.na(avg_estab_size)) %>%
  mutate(log_avg_size = log(avg_estab_size))

cs_nyt <- att_gt(
  yname = "log_avg_size",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = panel_nyt,
  control_group = "notyettreated",
  base_period = "universal",
  print_details = FALSE
)

att_nyt <- aggte(cs_nyt, type = "simple")
es_nyt <- aggte(cs_nyt, type = "dynamic", min_e = -10, max_e = 20)

cat(sprintf("Not-yet-treated — ATT: %.4f (SE: %.4f)\n",
            att_nyt$overall.att, att_nyt$overall.se))

saveRDS(att_nyt, "../data/rob_att_nyt.rds")
saveRDS(es_nyt, "../data/rob_es_nyt.rds")

# ============================================================
# 3. DROP DELAWARE (extreme incorporation state)
# ============================================================

cat("\n--- 3. Drop Delaware ---\n")

panel_no_de <- panel %>%
  filter(state_fips != "10") %>%
  mutate(state_id = as.integer(factor(state_fips)))

panel_no_de_cs <- panel_no_de %>%
  filter(year >= 1988, year <= 2019, !is.na(avg_estab_size)) %>%
  mutate(log_avg_size = log(avg_estab_size))

cs_no_de <- att_gt(
  yname = "log_avg_size",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = panel_no_de_cs,
  control_group = "nevertreated",
  base_period = "universal",
  print_details = FALSE
)

att_no_de <- aggte(cs_no_de, type = "simple")
cat(sprintf("Drop Delaware — ATT: %.4f (SE: %.4f)\n",
            att_no_de$overall.att, att_no_de$overall.se))

saveRDS(att_no_de, "../data/rob_att_no_de.rds")

# ============================================================
# 4. PLACEBO TEST: Fake treatment dates (shift 5 years earlier)
# ============================================================

cat("\n--- 4. Placebo test (late adopters only) ---\n")

# Use only late adopters (1989+) who have pre-treatment data in CBP
# Shift their treatment 3 years earlier (still within data window)
panel_placebo <- panel %>%
  filter(year >= 1988, year <= 2019, !is.na(avg_estab_size)) %>%
  mutate(log_avg_size = log(avg_estab_size)) %>%
  # Keep only late adopters (1991+) and never-treated
  filter(first_treat >= 1991 | first_treat == 0) %>%
  mutate(
    # Shift treatment 3 years earlier
    first_treat_placebo = ifelse(first_treat > 0, first_treat - 3, 0),
    # Only use data before actual treatment
    include = ifelse(first_treat > 0, year < first_treat, TRUE)
  ) %>%
  filter(include) %>%
  # Re-index state_id
  mutate(state_id = as.integer(factor(state_fips)))

cat(sprintf("  Placebo panel: %d obs, %d states\n", nrow(panel_placebo),
            n_distinct(panel_placebo$state_fips)))

tryCatch({
  cs_placebo <- att_gt(
    yname = "log_avg_size",
    tname = "year",
    idname = "state_id",
    gname = "first_treat_placebo",
    data = panel_placebo,
    control_group = "nevertreated",
    base_period = "universal",
    print_details = FALSE
  )

  att_placebo <- aggte(cs_placebo, type = "simple", na.rm = TRUE)
  cat(sprintf("Placebo (fake dates) — ATT: %.4f (SE: %.4f)\n",
              att_placebo$overall.att, att_placebo$overall.se))

  saveRDS(att_placebo, "../data/rob_att_placebo.rds")
}, error = function(e) {
  cat(sprintf("Placebo test error: %s\n", e$message))
  cat("Skipping placebo test.\n")
})

# ============================================================
# 5. RANDOMIZATION INFERENCE
# ============================================================

cat("\n--- 5. Randomization inference ---\n")

# Get the actual ATT
actual_att <- readRDS("../data/att_size.rds")$overall.att

# Permute treatment assignment 500 times
set.seed(42)
n_perms <- 500
perm_atts <- numeric(n_perms)

panel_ri <- panel %>%
  filter(year >= 1988, year <= 2019, !is.na(avg_estab_size)) %>%
  mutate(log_avg_size = log(avg_estab_size))

# Get unique state treatment status
state_treats <- panel_ri %>%
  distinct(state_id, first_treat)

for (i in 1:n_perms) {
  if (i %% 50 == 0) cat(sprintf("  Permutation %d/%d\n", i, n_perms))

  # Permute treatment assignment
  perm_treats <- state_treats %>%
    mutate(first_treat_perm = sample(first_treat))

  panel_perm <- panel_ri %>%
    select(-first_treat) %>%
    left_join(perm_treats %>% select(state_id, first_treat_perm),
              by = "state_id") %>%
    rename(first_treat = first_treat_perm)

  tryCatch({
    cs_perm <- att_gt(
      yname = "log_avg_size",
      tname = "year",
      idname = "state_id",
      gname = "first_treat",
      data = panel_perm,
      control_group = "nevertreated",
      base_period = "universal",
      print_details = FALSE
    )
    att_perm <- aggte(cs_perm, type = "simple")
    perm_atts[i] <- att_perm$overall.att
  }, error = function(e) {
    perm_atts[i] <<- NA
  })
}

ri_pvalue <- mean(abs(perm_atts[!is.na(perm_atts)]) >= abs(actual_att), na.rm = TRUE)
cat(sprintf("RI p-value: %.3f (actual ATT: %.4f)\n", ri_pvalue, actual_att))

saveRDS(list(
  actual_att = actual_att,
  perm_atts = perm_atts,
  ri_pvalue = ri_pvalue
), "../data/rob_ri.rds")

# ============================================================
# 6. WAGE ROBUSTNESS (Not-yet-treated controls)
# ============================================================

cat("\n--- 6. Wage robustness (NYT controls) ---\n")

if (file.exists("../data/cs_wage_gt.rds")) {
  panel_wage_nyt <- panel %>%
    filter(year >= 1988, year <= 2019,
           !is.na(payroll_per_worker), payroll_per_worker > 0) %>%
    mutate(log_wage = log(payroll_per_worker))

  cs_wage_nyt <- att_gt(
    yname = "log_wage",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = panel_wage_nyt,
    control_group = "notyettreated",
    base_period = "universal",
    print_details = FALSE
  )

  att_wage_nyt <- aggte(cs_wage_nyt, type = "simple")
  cat(sprintf("Log wage (NYT controls) — ATT: %.4f (SE: %.4f)\n",
              att_wage_nyt$overall.att, att_wage_nyt$overall.se))

  saveRDS(att_wage_nyt, "../data/rob_att_wage_nyt.rds")
}

# ============================================================
# 7. SUN-ABRAHAM ESTIMATOR (via fixest::sunab)
# ============================================================

cat("\n--- 7. Sun-Abraham estimator ---\n")

panel_sa <- panel %>%
  filter(year >= 1988, year <= 2019, !is.na(avg_estab_size)) %>%
  mutate(
    log_avg_size = log(avg_estab_size),
    # sunab needs Inf for never-treated
    cohort = ifelse(first_treat == 0, Inf, first_treat)
  )

sa_size <- feols(log_avg_size ~ sunab(cohort, year) | state_id + year,
                 data = panel_sa, cluster = ~state_id)

cat("Sun-Abraham estimates:\n")
print(summary(sa_size))
saveRDS(sa_size, "../data/rob_sa_size.rds")

cat("\n=== ROBUSTNESS CHECKS COMPLETE ===\n")
