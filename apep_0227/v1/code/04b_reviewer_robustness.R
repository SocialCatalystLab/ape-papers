## ============================================================================
## 04b_reviewer_robustness.R — Additional robustness checks per reviewer requests
## APEP Working Paper apep_0225
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
df <- readRDS(file.path(data_dir, "analysis_panel.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robust_results <- readRDS(file.path(data_dir, "robustness_results.rds"))

## Helper
aggregate_attgt <- function(out, type = "simple") {
  gt_df <- data.frame(
    group = out$group, time = out$t,
    att = out$att, se = out$se
  ) %>% filter(!is.na(att))
  if (type == "simple") {
    post <- gt_df %>% filter(time >= group)
    list(
      overall.att = mean(post$att, na.rm = TRUE),
      overall.se = sqrt(mean(post$se^2, na.rm = TRUE) / nrow(post)),
      n_gt = nrow(post)
    )
  }
}

cs_df <- df %>%
  filter(!is.na(first_treat)) %>%
  mutate(gname = first_treat, id = state_id)

## ---------------------------------------------------------------------------
## 1. Randomization Inference with 1000 permutations
## ---------------------------------------------------------------------------

cat("=== RI with 1000 permutations ===\n")

set.seed(20250225)
actual_att <- results$cs_agg_never$overall.att

treated_states <- cs_df %>%
  filter(first_treat > 0) %>%
  distinct(id, first_treat) %>%
  pull(first_treat)

n_perms <- 1000
perm_atts <- numeric(n_perms)

cat("Running", n_perms, "permutations...\n")
for (p in 1:n_perms) {
  if (p %% 100 == 0) cat("  Permutation", p, "\n")

  perm_df <- cs_df
  treated_ids <- cs_df %>%
    filter(first_treat > 0) %>%
    distinct(id) %>%
    pull(id)

  shuffled_gnames <- sample(treated_states)
  id_map <- tibble(id = treated_ids, new_gname = shuffled_gnames[1:length(treated_ids)])

  perm_df <- perm_df %>%
    left_join(id_map, by = "id") %>%
    mutate(gname_perm = ifelse(first_treat == 0, 0L, new_gname)) %>%
    select(-new_gname)

  tryCatch({
    cs_perm <- att_gt(
      yname = "rate_synth_opioid",
      tname = "year", idname = "id", gname = "gname_perm",
      data = perm_df, control_group = "nevertreated",
      est_method = "dr", bstrap = FALSE, print_details = FALSE
    )
    cs_perm_agg <- aggregate_attgt(cs_perm, type = "simple")
    perm_atts[p] <- cs_perm_agg$overall.att
  }, error = function(e) {
    perm_atts[p] <- NA
  })
}

perm_atts_valid <- perm_atts[!is.na(perm_atts)]
ri_pvalue_1000 <- mean(abs(perm_atts_valid) >= abs(actual_att))

cat("RI p-value (1000 perms):", round(ri_pvalue_1000, 4), "\n")
cat("Perm distribution: mean =", round(mean(perm_atts_valid), 3),
    "sd =", round(sd(perm_atts_valid), 3), "\n")

robust_results$ri_pvalue_1000 <- ri_pvalue_1000
robust_results$perm_atts_1000 <- perm_atts_valid

## ---------------------------------------------------------------------------
## 2. Leave-One-Out Analysis (drop each treated state)
## ---------------------------------------------------------------------------

cat("\n=== Leave-One-Out Aggregate ATT ===\n")

treated_ids <- cs_df %>%
  filter(first_treat > 0) %>%
  distinct(id, state_abb = NA) %>%
  pull(id)

# Get state abbreviations mapping
state_map <- cs_df %>% distinct(id, state_abb)

loo_results <- list()

for (drop_id in treated_ids) {
  drop_abb <- state_map$state_abb[state_map$id == drop_id]

  loo_df <- cs_df %>% filter(id != drop_id)

  tryCatch({
    cs_loo <- att_gt(
      yname = "rate_synth_opioid",
      tname = "year", idname = "id", gname = "gname",
      data = loo_df, control_group = "nevertreated",
      est_method = "dr", bstrap = FALSE, print_details = FALSE
    )
    cs_loo_agg <- aggregate_attgt(cs_loo, type = "simple")
    loo_results[[drop_abb]] <- cs_loo_agg$overall.att
    cat("  Drop", drop_abb, ": ATT =", round(cs_loo_agg$overall.att, 3), "\n")
  }, error = function(e) {
    cat("  Drop", drop_abb, ": Error:", conditionMessage(e), "\n")
  })
}

robust_results$leave_one_out <- loo_results

## ---------------------------------------------------------------------------
## 3. TWFE with State-Specific Linear Trends
## ---------------------------------------------------------------------------

cat("\n=== TWFE with State-Specific Linear Trends ===\n")

df_trends <- df %>%
  filter(!is.na(first_treat)) %>%
  mutate(
    treated = as.integer(!is.na(first_treat) & first_treat > 0 & year >= first_treat),
    poverty_pct = poverty_rate * 100,
    unemp_pct = unemp_rate * 100,
    state_trend = as.numeric(year - 2015)  # 0-8
  )

twfe_trends <- feols(
  rate_synth_opioid ~ treated + naloxone_law + medicaid_expanded +
    poverty_pct + unemp_pct | state_abb + year + state_abb[state_trend],
  data = df_trends, cluster = ~ state_abb
)

twfe_trends_sum <- summary(twfe_trends)
twfe_p <- fixest::pvalue(twfe_trends)["treated"]
cat("TWFE + state trends: coef =", round(coef(twfe_trends)["treated"], 3),
    "SE =", round(se(twfe_trends)["treated"], 3),
    "p =", round(twfe_p, 3), "\n")

robust_results$twfe_state_trends <- list(
  coef = coef(twfe_trends)["treated"],
  se = se(twfe_trends)["treated"],
  pvalue = twfe_p
)

## ---------------------------------------------------------------------------
## 4. Sensitivity: Include Ambiguous States as Controls
## ---------------------------------------------------------------------------

cat("\n=== Sensitivity: Ambiguous States as Controls ===\n")

# Reload raw data and add ambiguous states as controls
raw_df <- readRDS(file.path(data_dir, "analysis_panel.rds"))

# Check if ambiguous states are already in data
ambiguous <- c("AK", "NE", "OR", "WY")
cat("Ambiguous states in data:", sum(raw_df$state_abb %in% ambiguous), "rows\n")

if (sum(raw_df$state_abb %in% ambiguous) == 0) {
  cat("Ambiguous states not in panel — need to reconstruct\n")
  cat("Skipping this sensitivity check (states excluded during data construction)\n")
  robust_results$ambiguous_sensitivity <- "Not available — ambiguous states excluded during data construction"
} else {
  amb_df <- raw_df %>%
    mutate(
      first_treat = ifelse(state_abb %in% ambiguous, 0, first_treat)
    ) %>%
    filter(!is.na(first_treat)) %>%
    mutate(gname = first_treat, id = state_id)

  tryCatch({
    cs_amb <- att_gt(
      yname = "rate_synth_opioid",
      tname = "year", idname = "id", gname = "gname",
      data = amb_df, control_group = "nevertreated",
      est_method = "dr", bstrap = TRUE, biters = 1000,
      clustervars = "id", print_details = FALSE
    )
    cs_amb_agg <- aggregate_attgt(cs_amb, type = "simple")
    cat("ATT (ambiguous as controls):", round(cs_amb_agg$overall.att, 3),
        "SE:", round(cs_amb_agg$overall.se, 3), "\n")
    robust_results$ambiguous_sensitivity <- cs_amb_agg
  }, error = function(e) {
    cat("Error:", conditionMessage(e), "\n")
  })
}

## ---------------------------------------------------------------------------
## Save updated results
## ---------------------------------------------------------------------------

saveRDS(robust_results, file.path(data_dir, "robustness_results.rds"))
cat("\n=== Reviewer robustness checks complete ===\n")
