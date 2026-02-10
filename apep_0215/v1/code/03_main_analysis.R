## =============================================================================
## 03_main_analysis.R — Primary DiD estimation
## The Innovation Cost of Privacy
## =============================================================================

source(here::here("output", "apep_0214", "v1", "code", "00_packages.R"))

data_dir <- file.path(base_dir, "data")
tab_dir  <- file.path(base_dir, "tables")

# ==== 1. Load analysis data ====
panel <- read_csv(file.path(data_dir, "panel_information.csv"), show_col_types = FALSE)
bfs   <- read_csv(file.path(data_dir, "panel_bfs.csv"), show_col_types = FALSE)

cat(sprintf("Information panel: %d obs, %d states, %d periods\n",
            nrow(panel), n_distinct(panel$state_abbr), n_distinct(panel$period)))
cat(sprintf("BFS panel: %d obs, %d states\n",
            nrow(bfs), n_distinct(bfs$geo)))

# ==== 2. Summary Statistics ====
cat("\n=== Pre-treatment summary (2019) ===\n")

pre_stats <- panel %>%
  filter(year == 2019) %>%
  group_by(treated = first_treat > 0) %>%
  summarise(
    n_states = n_distinct(state_abbr),
    mean_emp = mean(avg_emp, na.rm = TRUE),
    sd_emp = sd(avg_emp, na.rm = TRUE),
    mean_estabs = mean(qtrly_estabs, na.rm = TRUE),
    mean_wage = mean(avg_wkly_wage, na.rm = TRUE),
    .groups = "drop"
  )
print(pre_stats)

# Save summary statistics
write_csv(pre_stats, file.path(tab_dir, "summary_stats.csv"))


# ==== 3. Callaway-Sant'Anna DiD ====
cat("\n=== Callaway-Sant'Anna estimation ===\n")

# 3a. Employment (primary outcome)
cat("Estimating: Log Employment in Information Sector\n")
cs_emp <- att_gt(
  yname = "log_emp",
  tname = "period",
  idname = "state_id",
  gname = "first_treat",
  data = panel %>% filter(!is.na(log_emp)),
  control_group = "nevertreated",
  est_method = "dr",  # Doubly robust
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

# Aggregate to event study
es_emp <- aggte(cs_emp, type = "dynamic", min_e = -8, max_e = 8)
cat("Event study (employment):\n")
summary(es_emp)

# Overall ATT
att_emp <- aggte(cs_emp, type = "simple")
cat("\nOverall ATT (employment):\n")
summary(att_emp)


# 3b. Establishments
cat("\nEstimating: Log Establishments in Information Sector\n")
cs_estabs <- att_gt(
  yname = "log_estabs",
  tname = "period",
  idname = "state_id",
  gname = "first_treat",
  data = panel %>% filter(!is.na(log_estabs)),
  control_group = "nevertreated",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

es_estabs <- aggte(cs_estabs, type = "dynamic", min_e = -8, max_e = 8)
att_estabs <- aggte(cs_estabs, type = "simple")

cat("Event study (establishments):\n")
summary(es_estabs)
cat("\nOverall ATT (establishments):\n")
summary(att_estabs)


# 3c. Wages
cat("\nEstimating: Log Average Weekly Wages in Information Sector\n")
cs_wages <- att_gt(
  yname = "log_wages",
  tname = "period",
  idname = "state_id",
  gname = "first_treat",
  data = panel %>% filter(!is.na(log_wages)),
  control_group = "nevertreated",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

es_wages <- aggte(cs_wages, type = "dynamic", min_e = -8, max_e = 8)
att_wages <- aggte(cs_wages, type = "simple")

cat("Event study (wages):\n")
summary(es_wages)


# 3d. Business Applications (BFS)
cat("\nEstimating: Log Business Applications\n")
cs_bfs <- att_gt(
  yname = "log_apps",
  tname = "period",
  idname = "state_id",
  gname = "first_treat",
  data = bfs %>% filter(!is.na(log_apps)),
  control_group = "nevertreated",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

es_bfs <- aggte(cs_bfs, type = "dynamic", min_e = -8, max_e = 8)
att_bfs <- aggte(cs_bfs, type = "simple")

cat("Event study (business applications):\n")
summary(es_bfs)


# ==== 3e. Software Publishers (primary narrow specification) ====
cat("\nEstimating: Log Employment in Software Publishers (NAICS 5112)\n")
panel_soft <- read_csv(file.path(data_dir, "panel_software.csv"), show_col_types = FALSE)

cs_soft <- att_gt(
  yname = "log_emp",
  tname = "period",
  idname = "state_id",
  gname = "first_treat",
  data = panel_soft %>% filter(!is.na(log_emp)),
  control_group = "nevertreated",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

es_soft <- aggte(cs_soft, type = "dynamic", min_e = -8, max_e = 8)
att_soft <- aggte(cs_soft, type = "simple")
cat("Software Publishers ATT:\n")
summary(att_soft)


# ==== 4. TWFE (for comparison / Bacon decomposition) ====
cat("\n=== Two-Way Fixed Effects (reference) ===\n")

twfe_emp <- feols(log_emp ~ treated | state_id + period,
                  data = panel, cluster = ~state_id)
cat("TWFE Employment:\n")
summary(twfe_emp)

twfe_estabs <- feols(log_estabs ~ treated | state_id + period,
                     data = panel, cluster = ~state_id)

twfe_wages <- feols(log_wages ~ treated | state_id + period,
                    data = panel, cluster = ~state_id)

twfe_bfs <- feols(log_apps ~ treated | state_id + period,
                  data = bfs, cluster = ~state_id)

twfe_soft <- feols(log_emp ~ treated | state_id + period,
                   data = panel_soft, cluster = ~state_id)
cat("TWFE Software Publishers:\n")
summary(twfe_soft)


# ==== 5. Sun-Abraham event study (fixest) ====
cat("\n=== Sun-Abraham event study ===\n")

# Need cohort variable for sunab()
panel_sa <- panel %>%
  mutate(cohort = ifelse(first_treat == 0, 10000, first_treat))  # Never-treated = far future

sa_emp <- feols(log_emp ~ sunab(cohort, period) | state_id + period,
                data = panel_sa, cluster = ~state_id)
cat("Sun-Abraham Employment:\n")
summary(sa_emp)


# ==== 6. Save results ====
results <- list(
  cs_emp = cs_emp,
  cs_estabs = cs_estabs,
  cs_wages = cs_wages,
  cs_bfs = cs_bfs,
  cs_soft = cs_soft,
  es_emp = es_emp,
  es_estabs = es_estabs,
  es_wages = es_wages,
  es_bfs = es_bfs,
  es_soft = es_soft,
  att_emp = att_emp,
  att_estabs = att_estabs,
  att_wages = att_wages,
  att_bfs = att_bfs,
  att_soft = att_soft,
  twfe_emp = twfe_emp,
  twfe_estabs = twfe_estabs,
  twfe_wages = twfe_wages,
  twfe_bfs = twfe_bfs,
  twfe_soft = twfe_soft,
  sa_emp = sa_emp
)

saveRDS(results, file.path(data_dir, "main_results.rds"))
cat("\nMain results saved to main_results.rds\n")

# ==== 7. Results table ====
cat("\n=== Results Summary ===\n")
results_table <- tibble(
  Outcome = c("Log Employment", "Log Establishments", "Log Avg Weekly Wages", "Log Business Applications"),
  `CS-DiD ATT` = c(att_emp$overall.att, att_estabs$overall.att,
                    att_wages$overall.att, att_bfs$overall.att),
  `CS SE` = c(att_emp$overall.se, att_estabs$overall.se,
              att_wages$overall.se, att_bfs$overall.se),
  `TWFE Coef` = c(coef(twfe_emp)["treated"], coef(twfe_estabs)["treated"],
                   coef(twfe_wages)["treated"], coef(twfe_bfs)["treated"]),
  `TWFE SE` = c(se(twfe_emp)["treated"], se(twfe_estabs)["treated"],
                 se(twfe_wages)["treated"], se(twfe_bfs)["treated"])
)

print(results_table)
write_csv(results_table, file.path(tab_dir, "main_results.csv"))

cat("\n=== Main analysis complete ===\n")
