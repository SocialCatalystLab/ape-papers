## =============================================================================
## 04_robustness.R — Robustness checks and placebo tests
## The Innovation Cost of Privacy
## =============================================================================

source(here::here("output", "apep_0214", "v1", "code", "00_packages.R"))

data_dir <- file.path(base_dir, "data")
tab_dir  <- file.path(base_dir, "tables")

# ==== Load data ====
panel_manuf <- read_csv(file.path(data_dir, "panel_manufacturing.csv"), show_col_types = FALSE)
panel_health <- read_csv(file.path(data_dir, "panel_healthcare.csv"), show_col_types = FALSE)
panel_constr <- read_csv(file.path(data_dir, "panel_construction.csv"), show_col_types = FALSE)
panel_soft <- read_csv(file.path(data_dir, "panel_software.csv"), show_col_types = FALSE)
panel_info <- read_csv(file.path(data_dir, "panel_information.csv"), show_col_types = FALSE)
panel_bfs <- read_csv(file.path(data_dir, "panel_bfs.csv"), show_col_types = FALSE)

main_results <- readRDS(file.path(data_dir, "main_results.rds"))


# ==== 1. Placebo Industry Tests ====
cat("=== Placebo Industries ===\n")

run_placebo <- function(data, label) {
  cat(sprintf("Running CS-DiD for %s...\n", label))
  tryCatch({
    cs <- att_gt(
      yname = "log_emp",
      tname = "period",
      idname = "state_id",
      gname = "first_treat",
      data = data %>% filter(!is.na(log_emp)),
      control_group = "nevertreated",
      est_method = "dr",
      bstrap = TRUE,
      biters = 500
    )
    att <- aggte(cs, type = "simple")
    es <- aggte(cs, type = "dynamic", min_e = -8, max_e = 8)
    return(list(cs = cs, att = att, es = es))
  }, error = function(e) {
    cat(sprintf("  Error in %s: %s\n", label, e$message))
    return(NULL)
  })
}

placebo_manuf <- run_placebo(panel_manuf, "Manufacturing (NAICS 31-33)")
placebo_health <- run_placebo(panel_health, "Healthcare (NAICS 62)")
placebo_constr <- run_placebo(panel_constr, "Construction (NAICS 23)")

# Narrow tech: Software Publishers (NAICS 5112)
cat("\nRunning CS-DiD for Software Publishers (NAICS 5112)...\n")
cs_soft <- tryCatch({
  att_gt(
    yname = "log_emp",
    tname = "period",
    idname = "state_id",
    gname = "first_treat",
    data = panel_soft %>% filter(!is.na(log_emp)),
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 500
  )
}, error = function(e) {
  cat(sprintf("  Error: %s\n", e$message))
  NULL
})

if (!is.null(cs_soft)) {
  att_soft <- aggte(cs_soft, type = "simple")
  es_soft <- aggte(cs_soft, type = "dynamic", min_e = -8, max_e = 8)
  cat("Software Publishers ATT:\n")
  summary(att_soft)
}


# ==== 2. Including Florida ====
cat("\n=== Robustness: Including Florida ===\n")

# Add Florida as treated in 2024Q3 (FDBR effective July 2024)
panel_fl <- panel_info %>%
  mutate(
    first_treat_fl = case_when(
      state_abbr == "FL" ~ (2024 - 2015) * 4 + 3,  # 2024Q3 = period 39
      TRUE ~ first_treat
    )
  )

cs_fl <- tryCatch({
  att_gt(
    yname = "log_emp",
    tname = "period",
    idname = "state_id",
    gname = "first_treat_fl",
    data = panel_fl %>% filter(!is.na(log_emp)),
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 500
  )
}, error = function(e) {
  cat(sprintf("  Error: %s\n", e$message))
  NULL
})

if (!is.null(cs_fl)) {
  att_fl <- aggte(cs_fl, type = "simple")
  cat("With Florida ATT:\n")
  summary(att_fl)
}


# ==== 3. Randomization Inference (Software Publishers — primary spec) ====
cat("\n=== Randomization Inference (NAICS 5112) ===\n")

# Permute treatment assignment 500 times and re-estimate on Software Publishers
observed_att <- main_results$att_soft$overall.att

n_perms <- 500
perm_atts <- numeric(n_perms)

unique_states <- unique(panel_soft$state_id)
n_treated <- sum(panel_soft$first_treat > 0) / n_distinct(panel_soft$period)

for (i in 1:n_perms) {
  if (i %% 50 == 0) cat(sprintf("\rPermutation %d/%d", i, n_perms))

  # Randomly assign treatment status
  fake_treated <- sample(unique_states, size = round(n_treated))

  perm_data <- panel_soft %>%
    mutate(
      first_treat_perm = ifelse(state_id %in% fake_treated, first_treat, 0),
      # For randomly treated states without a real treatment date, assign random cohort
      first_treat_perm = ifelse(first_treat_perm == 0 & state_id %in% fake_treated,
                                 sample(panel_soft$first_treat[panel_soft$first_treat > 0], 1),
                                 first_treat_perm)
    )

  perm_cs <- tryCatch({
    cs <- att_gt(
      yname = "log_emp",
      tname = "period",
      idname = "state_id",
      gname = "first_treat_perm",
      data = perm_data %>% filter(!is.na(log_emp)),
      control_group = "nevertreated",
      est_method = "reg",
      bstrap = FALSE
    )
    att <- aggte(cs, type = "simple")
    att$overall.att
  }, error = function(e) NA)

  perm_atts[i] <- perm_cs
}

cat("\n")
perm_atts_clean <- perm_atts[!is.na(perm_atts)]
ri_pvalue <- mean(abs(perm_atts_clean) >= abs(observed_att))

cat(sprintf("Observed ATT: %.4f\n", observed_att))
cat(sprintf("RI p-value (two-sided): %.4f (based on %d valid permutations)\n",
            ri_pvalue, length(perm_atts_clean)))


# ==== 4. Heterogeneity by baseline tech intensity ====
cat("\n=== Heterogeneity: Tech Intensity ===\n")

# Compute baseline (2019) share of Information sector employment
panel_total <- read_csv(file.path(data_dir, "panel_total.csv"), show_col_types = FALSE)

baseline_tech <- panel_info %>%
  filter(year == 2019) %>%
  group_by(state_abbr) %>%
  summarise(info_emp_2019 = mean(avg_emp, na.rm = TRUE), .groups = "drop") %>%
  left_join(
    panel_total %>%
      filter(year == 2019) %>%
      group_by(state_abbr) %>%
      summarise(total_emp_2019 = mean(avg_emp, na.rm = TRUE), .groups = "drop"),
    by = "state_abbr"
  ) %>%
  mutate(
    tech_share = info_emp_2019 / total_emp_2019,
    high_tech = tech_share > median(tech_share, na.rm = TRUE)
  )

# Merge back
panel_het <- panel_info %>%
  left_join(baseline_tech %>% select(state_abbr, high_tech, tech_share), by = "state_abbr")

# High-tech states
cs_high <- tryCatch({
  att_gt(
    yname = "log_emp",
    tname = "period",
    idname = "state_id",
    gname = "first_treat",
    data = panel_het %>% filter(high_tech == TRUE, !is.na(log_emp)),
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 500
  )
}, error = function(e) { cat(sprintf("Error: %s\n", e$message)); NULL })

if (!is.null(cs_high)) {
  att_high <- aggte(cs_high, type = "simple")
  cat("High-tech states ATT:\n")
  summary(att_high)
}

# Low-tech states
cs_low <- tryCatch({
  att_gt(
    yname = "log_emp",
    tname = "period",
    idname = "state_id",
    gname = "first_treat",
    data = panel_het %>% filter(high_tech == FALSE, !is.na(log_emp)),
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 500
  )
}, error = function(e) { cat(sprintf("Error: %s\n", e$message)); NULL })

if (!is.null(cs_low)) {
  att_low <- aggte(cs_low, type = "simple")
  cat("Low-tech states ATT:\n")
  summary(att_low)
}


# ==== 5. Save robustness results ====
robustness <- list(
  placebo_manuf = placebo_manuf,
  placebo_health = placebo_health,
  placebo_constr = placebo_constr,
  cs_soft = if (exists("cs_soft") && !is.null(cs_soft)) list(cs = cs_soft, att = att_soft, es = es_soft) else NULL,
  cs_fl = if (!is.null(cs_fl)) list(cs = cs_fl, att = att_fl) else NULL,
  ri_pvalue = ri_pvalue,
  ri_observed = observed_att,
  ri_distribution = perm_atts_clean,
  het_high = if (!is.null(cs_high)) list(cs = cs_high, att = att_high) else NULL,
  het_low = if (!is.null(cs_low)) list(cs = cs_low, att = att_low) else NULL,
  baseline_tech = baseline_tech
)

saveRDS(robustness, file.path(data_dir, "robustness_results.rds"))

# Summary table
rob_table <- tribble(
  ~Specification, ~ATT, ~SE, ~Note,
  "Main (NAICS 51)", main_results$att_emp$overall.att, main_results$att_emp$overall.se, "Primary",
  "Software (5112)", ifelse(!is.null(cs_soft), att_soft$overall.att, NA), ifelse(!is.null(cs_soft), att_soft$overall.se, NA), "Narrow tech",
  "Including Florida", ifelse(!is.null(cs_fl), att_fl$overall.att, NA), ifelse(!is.null(cs_fl), att_fl$overall.se, NA), "FL added",
  "Placebo: Manuf", ifelse(!is.null(placebo_manuf), placebo_manuf$att$overall.att, NA), ifelse(!is.null(placebo_manuf), placebo_manuf$att$overall.se, NA), "Placebo",
  "Placebo: Health", ifelse(!is.null(placebo_health), placebo_health$att$overall.att, NA), ifelse(!is.null(placebo_health), placebo_health$att$overall.se, NA), "Placebo",
  "Placebo: Constr", ifelse(!is.null(placebo_constr), placebo_constr$att$overall.att, NA), ifelse(!is.null(placebo_constr), placebo_constr$att$overall.se, NA), "Placebo",
  "High-tech states", ifelse(!is.null(cs_high), att_high$overall.att, NA), ifelse(!is.null(cs_high), att_high$overall.se, NA), "Heterogeneity",
  "Low-tech states", ifelse(!is.null(cs_low), att_low$overall.att, NA), ifelse(!is.null(cs_low), att_low$overall.se, NA), "Heterogeneity"
)

write_csv(rob_table, file.path(tab_dir, "robustness_table.csv"))
print(rob_table)

cat("\n=== Robustness checks complete ===\n")
