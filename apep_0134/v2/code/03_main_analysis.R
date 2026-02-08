# ==============================================================================
# 03_main_analysis.R
# Synthetic Control and DiD Analysis for NYC OPCs
# Paper 134: Do Supervised Drug Injection Sites Save Lives?
# ==============================================================================

# Source packages - assumes running from code/ directory or project root
if (file.exists("00_packages.R")) {
  source("00_packages.R")
} else if (file.exists("code/00_packages.R")) {
  source("code/00_packages.R")
} else {
  stop("Cannot find 00_packages.R - run from code/ directory or project root")
}

# Load data
panel_data <- read_csv(file.path(PAPER_DIR, "data", "panel_data.csv"))

# ==============================================================================
# ANALYSIS 1: Synthetic Control for East Harlem (UHF 203)
# ==============================================================================

cat("\n=== Synthetic Control: East Harlem ===\n")

# Prepare data for Synth package
# Exclude treated and spillover UHFs from donor pool
donor_uhfs <- panel_data %>%
  filter(treatment_status == "control") %>%
  pull(uhf_id) %>%
  unique()

east_harlem_data <- panel_data %>%
  filter(uhf_id == 203 | uhf_id %in% donor_uhfs)

# Create wide format for Synth
wide_data <- east_harlem_data %>%
  select(uhf_id, year, od_rate) %>%
  pivot_wider(names_from = uhf_id, values_from = od_rate)

# Augmented Synthetic Control (Synth + Ridge)
# Treatment year = 2022 (first full year after Nov 2021 opening)

if (require(augsynth)) {
  # Prepare data for augsynth
  synth_data <- panel_data %>%
    filter(uhf_id == 203 | treatment_status == "control") %>%
    mutate(
      treat = ifelse(uhf_id == 203, 1, 0),
      post = ifelse(year >= 2022, 1, 0)
    )

  # Augmented synthetic control
  asyn_east_harlem <- augsynth(
    od_rate ~ treat,
    unit = uhf_id,
    time = year,
    data = synth_data,
    progfunc = "ridge",
    scm = TRUE
  )

  cat("\nAugmented Synthetic Control Results - East Harlem:\n")
  print(summary(asyn_east_harlem))

  # Extract treatment effect
  att_east_harlem <- summary(asyn_east_harlem)$att
  cat("\nATT (Average Treatment Effect on Treated):", round(att_east_harlem$Estimate, 2), "\n")
}

# ==============================================================================
# ANALYSIS 2: Synthetic Control for Washington Heights (UHF 201)
# ==============================================================================

cat("\n=== Synthetic Control: Washington Heights ===\n")

if (require(augsynth)) {
  synth_data_wh <- panel_data %>%
    filter(uhf_id == 201 | treatment_status == "control") %>%
    mutate(
      treat = ifelse(uhf_id == 201, 1, 0),
      post = ifelse(year >= 2022, 1, 0)
    )

  asyn_washington_heights <- augsynth(
    od_rate ~ treat,
    unit = uhf_id,
    time = year,
    data = synth_data_wh,
    progfunc = "ridge",
    scm = TRUE
  )

  cat("\nAugmented Synthetic Control Results - Washington Heights:\n")
  print(summary(asyn_washington_heights))

  att_wh <- summary(asyn_washington_heights)$att
  cat("\nATT (Average Treatment Effect on Treated):", round(att_wh$Estimate, 2), "\n")
}

# ==============================================================================
# ANALYSIS 3: Pooled Synthetic Control (Both Treated Units)
# ==============================================================================

cat("\n=== Pooled Synthetic Control: Both OPC Neighborhoods ===\n")

if (require(augsynth)) {
  synth_data_pooled <- panel_data %>%
    filter(treatment_status %in% c("treated", "control")) %>%
    mutate(
      treat = ifelse(treatment_status == "treated", 1, 0),
      post = ifelse(year >= 2022, 1, 0)
    )

  asyn_pooled <- augsynth(
    od_rate ~ treat,
    unit = uhf_id,
    time = year,
    data = synth_data_pooled,
    progfunc = "ridge",
    scm = TRUE
  )

  cat("\nPooled Augmented Synthetic Control Results:\n")
  print(summary(asyn_pooled))
}

# ==============================================================================
# ANALYSIS 4: Difference-in-Differences (Robustness)
# ==============================================================================

cat("\n=== Difference-in-Differences ===\n")

# Prepare DiD data (exclude spillover for clean comparison)
did_data <- panel_data %>%
  filter(treatment_status %in% c("treated", "control")) %>%
  mutate(
    treat = ifelse(treatment_status == "treated", 1, 0),
    post = ifelse(year >= 2022, 1, 0)
  )

# Basic DiD with two-way fixed effects
did_basic <- feols(
  od_rate ~ treat:post | uhf_id + year,
  data = did_data,
  cluster = ~uhf_id
)

cat("\nBasic DiD Results:\n")
print(summary(did_basic))

# Event study - reference year is 2020 (last full pre-treatment year)
# 2021 is partial treatment (OPC opened late November 2021)
did_event <- feols(
  od_rate ~ i(year, treat, ref = 2020) | uhf_id + year,
  data = did_data,
  cluster = ~uhf_id
)

cat("\nEvent Study Results:\n")
print(summary(did_event))

# ==============================================================================
# ANALYSIS 5: Wild Cluster Bootstrap (Few Clusters)
# ==============================================================================

cat("\n=== Wild Cluster Bootstrap Inference ===\n")

if (require(fwildclusterboot)) {
  # Wild bootstrap with Webb weights for few clusters
  boot_result <- boottest(
    did_basic,
    clustid = "uhf_id",
    param = "treat:post",
    B = 9999,
    type = "webb"
  )

  cat("\nWild Cluster Bootstrap Results:\n")
  print(summary(boot_result))
}

# ==============================================================================
# ANALYSIS 6: Randomization Inference
# ==============================================================================

cat("\n=== Randomization Inference ===\n")

# Function to compute DiD estimate
compute_did <- function(data, treated_uhfs) {
  data <- data %>%
    mutate(
      treat = ifelse(uhf_id %in% treated_uhfs, 1, 0),
      post = ifelse(year >= 2022, 1, 0)
    )

  # DiD estimate
  pre_treat <- data %>% filter(treat == 1, post == 0) %>% pull(od_rate) %>% mean()
  post_treat <- data %>% filter(treat == 1, post == 1) %>% pull(od_rate) %>% mean()
  pre_control <- data %>% filter(treat == 0, post == 0) %>% pull(od_rate) %>% mean()
  post_control <- data %>% filter(treat == 0, post == 1) %>% pull(od_rate) %>% mean()

  (post_treat - pre_treat) - (post_control - pre_control)
}

# Observed effect
observed_effect <- compute_did(did_data, c(201, 203))
cat("Observed DiD Effect:", round(observed_effect, 2), "\n")

# Permutation test: randomly assign treatment to 2 UHFs
set.seed(20211130)
n_perms <- 1000
control_uhfs <- unique(did_data$uhf_id[did_data$treatment_status == "control"])
all_uhfs <- unique(did_data$uhf_id)

permuted_effects <- numeric(n_perms)
for (i in 1:n_perms) {
  # Randomly select 2 UHFs as "treated"
  fake_treated <- sample(all_uhfs, 2)
  permuted_effects[i] <- compute_did(did_data, fake_treated)
}

# P-value: proportion of permuted effects more extreme than observed
ri_pvalue <- mean(abs(permuted_effects) >= abs(observed_effect))
cat("Randomization Inference P-value:", round(ri_pvalue, 3), "\n")

# ==============================================================================
# ANALYSIS 7: Placebo-in-Time Tests
# ==============================================================================

cat("\n=== Placebo-in-Time Tests ===\n")

# Run synthetic control with fake treatment dates
placebo_years <- c(2016, 2017, 2018, 2019, 2020)

placebo_effects <- sapply(placebo_years, function(fake_year) {
  synth_data_placebo <- panel_data %>%
    filter(uhf_id == 203 | treatment_status == "control") %>%
    filter(year <= 2021) %>%  # Use only pre-treatment data
    mutate(
      treat = ifelse(uhf_id == 203, 1, 0),
      post = ifelse(year >= fake_year, 1, 0)
    )

  # Simple DiD for placebo
  pre_treat <- synth_data_placebo %>%
    filter(treat == 1, post == 0) %>%
    pull(od_rate) %>%
    mean(na.rm = TRUE)
  post_treat <- synth_data_placebo %>%
    filter(treat == 1, post == 1) %>%
    pull(od_rate) %>%
    mean(na.rm = TRUE)
  pre_control <- synth_data_placebo %>%
    filter(treat == 0, post == 0) %>%
    pull(od_rate) %>%
    mean(na.rm = TRUE)
  post_control <- synth_data_placebo %>%
    filter(treat == 0, post == 1) %>%
    pull(od_rate) %>%
    mean(na.rm = TRUE)

  (post_treat - pre_treat) - (post_control - pre_control)
})

names(placebo_effects) <- placebo_years
cat("\nPlacebo Effects (should be near zero):\n")
print(round(placebo_effects, 2))

# ==============================================================================
# Save Results
# ==============================================================================

results <- list(
  observed_effect = observed_effect,
  ri_pvalue = ri_pvalue,
  placebo_effects = placebo_effects,
  permuted_effects = permuted_effects,
  event_study = did_event,  # Add event study model for figure generation
  did_basic = did_basic
)

saveRDS(results, file.path(PAPER_DIR, "data", "analysis_results.rds"))

cat("\n=== Analysis Complete ===\n")
cat("Results saved to", file.path(PAPER_DIR, "data", "analysis_results.rds"), "\n")
