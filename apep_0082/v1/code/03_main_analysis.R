## 03_main_analysis.R — Primary regressions
## Paper 110: Recreational Marijuana and Business Formation

source("00_packages.R")

# ──────────────────────────────────────────────────────────────
# 1. Load analysis panels
# ──────────────────────────────────────────────────────────────
cat("Loading analysis datasets...\n")
state_year <- read_csv(file.path(DATA_DIR, "panel_state_year.csv"), show_col_types = FALSE)
sector_panel <- read_csv(file.path(DATA_DIR, "panel_sector.csv"), show_col_types = FALSE)

# Verify
cat("  State-year:", nrow(state_year), "obs,",
    n_distinct(state_year$state_abbr), "states,",
    min(state_year$year), "-", max(state_year$year), "\n")

# ──────────────────────────────────────────────────────────────
# 2. TWFE Estimates (for comparison/illustration)
# ──────────────────────────────────────────────────────────────
cat("\n=== TWFE Estimates ===\n")

# Model 1: Log applications
twfe1 <- feols(
  log_apps ~ treated | state_abbr + year,
  data = state_year,
  cluster = ~state_abbr
)

# Model 2: Log applications per capita
twfe2 <- feols(
  log_apps_pc ~ treated | state_abbr + year,
  data = state_year,
  cluster = ~state_abbr
)

# Model 3: With medical marijuana control
twfe3 <- feols(
  log_apps_pc ~ treated + has_medical | state_abbr + year,
  data = state_year,
  cluster = ~state_abbr
)

cat("TWFE results:\n")
cat("  Model 1 (log apps):    β =", round(coef(twfe1)["treated"], 4),
    "SE =", round(se(twfe1)["treated"], 4), "\n")
cat("  Model 2 (log apps/pc): β =", round(coef(twfe2)["treated"], 4),
    "SE =", round(se(twfe2)["treated"], 4), "\n")
cat("  Model 3 (+ medical):   β =", round(coef(twfe3)["treated"], 4),
    "SE =", round(se(twfe3)["treated"], 4), "\n")

# ──────────────────────────────────────────────────────────────
# 3. Callaway-Sant'Anna Estimates
# ──────────────────────────────────────────────────────────────
cat("\n=== Callaway-Sant'Anna Estimates ===\n")

# CS requires: idname, tname, gname (first_treat, 0 for never-treated), yname
# Need numeric state ID
state_year <- state_year %>%
  mutate(state_id = as.integer(factor(state_abbr)))

# Main CS estimate: log applications per capita
cs_main <- att_gt(
  yname = "log_apps_pc",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = state_year,
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal"
)

# Aggregate to overall ATT
cs_agg <- aggte(cs_main, type = "simple")
cat("CS Overall ATT:", round(cs_agg$overall.att, 4),
    "SE:", round(cs_agg$overall.se, 4), "\n")

# Dynamic event-study aggregation
cs_es <- aggte(cs_main, type = "dynamic", min_e = -7, max_e = 7)
cat("CS Event Study computed\n")

# By cohort
cs_cohort <- aggte(cs_main, type = "group")
cat("CS by cohort:\n")
for (i in seq_along(cs_cohort$egt)) {
  cat("  Cohort", cs_cohort$egt[i], ": ATT =",
      round(cs_cohort$att.egt[i], 4),
      "SE =", round(cs_cohort$se.egt[i], 4), "\n")
}

# ──────────────────────────────────────────────────────────────
# 4. CS for alternative outcomes (BFS series decomposition)
# ──────────────────────────────────────────────────────────────
cat("\n=== CS for Log Applications (levels) ===\n")

cs_levels <- att_gt(
  yname = "log_apps",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = state_year,
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal"
)
cs_levels_agg <- aggte(cs_levels, type = "simple")
cat("CS Overall ATT (log apps):", round(cs_levels_agg$overall.att, 4),
    "SE:", round(cs_levels_agg$overall.se, 4), "\n")

# ──────────────────────────────────────────────────────────────
# 5. TWFE across BFS series (decomposition analysis)
# ──────────────────────────────────────────────────────────────
cat("\n=== TWFE Across BFS Series ===\n")
cat("(Note: BFS provides sector data only at national level,\n")
cat(" so we use application-type decomposition instead of DDD)\n\n")

# Load alternative series panels
state_year_hba <- read_csv(file.path(DATA_DIR, "panel_state_year_hba.csv"), show_col_types = FALSE) %>%
  mutate(state_id = as.integer(factor(state_abbr)))
state_year_wba <- read_csv(file.path(DATA_DIR, "panel_state_year_wba.csv"), show_col_types = FALSE) %>%
  mutate(state_id = as.integer(factor(state_abbr)))
state_year_cba <- read_csv(file.path(DATA_DIR, "panel_state_year_cba.csv"), show_col_types = FALSE) %>%
  mutate(state_id = as.integer(factor(state_abbr)))
state_year_bf <- read_csv(file.path(DATA_DIR, "panel_state_year_bf.csv"), show_col_types = FALSE) %>%
  mutate(state_id = as.integer(factor(state_abbr)))

# TWFE for each series type
twfe_hba <- feols(
  log_apps_pc ~ treated | state_abbr + year,
  data = state_year_hba,
  cluster = ~state_abbr
)
cat("TWFE (HBA - high propensity): β =", round(coef(twfe_hba)["treated"], 4),
    "SE =", round(se(twfe_hba)["treated"], 4), "\n")

twfe_wba <- feols(
  log_apps_pc ~ treated | state_abbr + year,
  data = state_year_wba,
  cluster = ~state_abbr
)
cat("TWFE (WBA - planned wages):   β =", round(coef(twfe_wba)["treated"], 4),
    "SE =", round(se(twfe_wba)["treated"], 4), "\n")

twfe_cba <- feols(
  log_apps_pc ~ treated | state_abbr + year,
  data = state_year_cba,
  cluster = ~state_abbr
)
cat("TWFE (CBA - corporate):       β =", round(coef(twfe_cba)["treated"], 4),
    "SE =", round(se(twfe_cba)["treated"], 4), "\n")

twfe_bf <- feols(
  log_apps_pc ~ treated | state_abbr + year,
  data = state_year_bf %>% filter(!is.na(log_apps_pc) & is.finite(log_apps_pc)),
  cluster = ~state_abbr
)
cat("TWFE (BF8Q - actual formations): β =", round(coef(twfe_bf)["treated"], 4),
    "SE =", round(se(twfe_bf)["treated"], 4), "\n")

# ──────────────────────────────────────────────────────────────
# 6. Save results
# ──────────────────────────────────────────────────────────────
cat("\nSaving results...\n")

# Save CS objects
saveRDS(cs_main, file.path(DATA_DIR, "cs_main.rds"))
saveRDS(cs_es, file.path(DATA_DIR, "cs_es.rds"))
saveRDS(cs_cohort, file.path(DATA_DIR, "cs_cohort.rds"))

# Save TWFE models (main + series decomposition)
saveRDS(list(twfe1 = twfe1, twfe2 = twfe2, twfe3 = twfe3),
        file.path(DATA_DIR, "twfe_models.rds"))
saveRDS(list(twfe_hba = twfe_hba, twfe_wba = twfe_wba,
             twfe_cba = twfe_cba, twfe_bf = twfe_bf),
        file.path(DATA_DIR, "series_models.rds"))

cat("\n=== Main analysis complete ===\n")
