# =============================================================================
# 04_industry_analysis.R
# Industry-Specific Effects with Multiple Hypothesis Correction
# =============================================================================

source("00_packages.R")

# Load data
qwi_border <- readRDS(file.path(data_dir, "qwi_border.rds"))

cat("=== Industry Analysis ===\n")

# =============================================================================
# Industry Classification
# =============================================================================

industry_class <- tribble(
  ~industry, ~industry_name, ~category, ~predicted_effect,
  "11",    "Agriculture",           "Direct Cannabis",   "Strong +",
  "44-45", "Retail Trade",          "Direct Cannabis",   "Moderate +",
  "72",    "Accommodation & Food",  "Tourism Exposed",   "Moderate +",
  "48-49", "Transportation",        "DOT Regulated",     "Null/-",
  "31-33", "Manufacturing",         "Safety Sensitive",  "Null",
  "23",    "Construction",          "Safety Sensitive",  "Ambiguous",
  "54",    "Professional Services", "Low Testing",       "Null",
  "52",    "Finance",               "Low Testing",       "Null",
  "51",    "Information",           "Low Testing",       "Null",
  "62",    "Health Care",           "Safety Sensitive",  "Ambiguous",
  "21",    "Mining",                "Safety Sensitive",  "Null/-",
  "42",    "Wholesale Trade",       "Other",             "Null",
  "53",    "Real Estate",           "Other",             "Null",
  "55",    "Management",            "Other",             "Null",
  "56",    "Admin Services",        "Other",             "Null",
  "61",    "Education",             "Other",             "Null",
  "71",    "Arts & Entertainment",  "Tourism Exposed",   "Moderate +",
  "81",    "Other Services",        "Other",             "Null"
)

# Pre-specified groups (confirmatory)
confirmatory_industries <- c("11", "44-45", "48-49", "72")

# =============================================================================
# Estimate Effects by Industry
# =============================================================================

cat("\n=== Industry-by-Industry DiDisc ===\n")

industry_results <- list()

for (ind in unique(qwi_border$industry[qwi_border$industry != "00"])) {

  ind_sample <- qwi_border %>%
    filter(industry == ind, in_bandwidth) %>%
    mutate(
      # dist_km already in data,
      treat_post = treated * post
    )

  if (nrow(ind_sample) < 500 || n_distinct(ind_sample$border_pair) < 3) {
    cat(sprintf("  %s: insufficient data (%d obs)\n", ind, nrow(ind_sample)))
    next
  }

  ind_reg <- tryCatch({
    feols(
      log_earn_hire ~ treated + post + treat_post + dist_km + treated:dist_km |
        border_pair^quarter,
      data = ind_sample,
      cluster = ~border_pair
    )
  }, error = function(e) {
    cat(sprintf("  %s: estimation failed - %s\n", ind, e$message))
    return(NULL)
  })

  if (!is.null(ind_reg) && "treat_post" %in% names(coef(ind_reg))) {
    tau <- coef(ind_reg)["treat_post"]
    se <- sqrt(vcov(ind_reg)["treat_post", "treat_post"])

    industry_results[[length(industry_results) + 1]] <- tibble(
      industry = ind,
      tau = tau,
      se = se,
      t_stat = tau / se,
      p_value = 2 * pt(-abs(tau / se), df = n_distinct(ind_sample$border_pair) - 1),
      n_obs = nrow(ind_sample),
      n_borders = n_distinct(ind_sample$border_pair)
    )

    cat(sprintf("  %s: tau = %.4f (SE: %.4f), p = %.4f\n", ind, tau, se,
                industry_results[[length(industry_results)]]$p_value))
  }
}

# Combine results
industry_df <- bind_rows(industry_results) %>%
  left_join(industry_class, by = "industry") %>%
  arrange(p_value)

cat("\n=== Raw Results (Before Correction) ===\n")
print(industry_df %>% select(industry, industry_name, tau, se, p_value, category))

# =============================================================================
# Multiple Hypothesis Correction
# =============================================================================

cat("\n=== Multiple Hypothesis Correction ===\n")

# Benjamini-Hochberg FDR correction
industry_df <- industry_df %>%
  mutate(
    # FDR-adjusted p-values (all industries)
    p_fdr_all = p.adjust(p_value, method = "BH"),
    # Flag confirmatory vs exploratory
    confirmatory = industry %in% confirmatory_industries,
    # FDR within group
    rank = rank(p_value)
  )

# Separate correction for confirmatory (weaker correction due to pre-specification)
confirmatory_df <- industry_df %>%
  filter(confirmatory) %>%
  mutate(p_bonf_confirm = p.adjust(p_value, method = "bonferroni"))

exploratory_df <- industry_df %>%
  filter(!confirmatory) %>%
  mutate(p_fdr_explore = p.adjust(p_value, method = "BH"))

# Merge back
industry_df <- industry_df %>%
  left_join(confirmatory_df %>% select(industry, p_bonf_confirm), by = "industry") %>%
  left_join(exploratory_df %>% select(industry, p_fdr_explore), by = "industry")

# Final significance classification
industry_df <- industry_df %>%
  mutate(
    significant_raw = p_value < 0.05,
    significant_fdr = p_fdr_all < 0.05,
    # Appropriate correction based on pre-specification
    p_corrected = ifelse(confirmatory, p_bonf_confirm, p_fdr_explore),
    significant_corrected = p_corrected < 0.05
  )

cat("\n=== Results After FDR Correction ===\n")
print(industry_df %>%
        select(industry, industry_name, category, tau, se, p_value, p_fdr_all, significant_fdr) %>%
        arrange(p_fdr_all))

# =============================================================================
# Summary by Category
# =============================================================================

cat("\n=== Summary by Industry Category ===\n")

category_summary <- industry_df %>%
  group_by(category, predicted_effect) %>%
  summarise(
    n_industries = n(),
    mean_tau = mean(tau),
    pooled_se = sqrt(sum(se^2)) / n(),
    n_significant_raw = sum(significant_raw),
    n_significant_fdr = sum(significant_fdr),
    .groups = "drop"
  )

print(category_summary)

# =============================================================================
# Pooled Estimates by Pre-Specified Groups
# =============================================================================

cat("\n=== Pooled Estimates by Pre-Specified Category ===\n")

# Direct Cannabis (Agriculture + Retail)
direct_cannabis <- qwi_border %>%
  filter(industry %in% c("11", "44-45"), in_bandwidth) %>%
  mutate(
    # dist_km already in data,
    treat_post = treated * post
  )

if (nrow(direct_cannabis) > 1000) {
  pool_direct <- feols(
    log_earn_hire ~ treated + post + treat_post + dist_km + treated:dist_km |
      border_pair^quarter + industry,
    data = direct_cannabis,
    cluster = ~border_pair
  )
  cat("\n--- Direct Cannabis (Agriculture + Retail) ---\n")
  cat(sprintf("tau = %.4f (SE: %.4f)\n", coef(pool_direct)["treat_post"],
              sqrt(vcov(pool_direct)["treat_post", "treat_post"])))
}

# DOT Regulated (Transportation)
dot_regulated <- qwi_border %>%
  filter(industry == "48-49", in_bandwidth) %>%
  mutate(
    # dist_km already in data,
    treat_post = treated * post
  )

if (nrow(dot_regulated) > 500) {
  pool_dot <- feols(
    log_earn_hire ~ treated + post + treat_post + dist_km + treated:dist_km |
      border_pair^quarter,
    data = dot_regulated,
    cluster = ~border_pair
  )
  cat("\n--- DOT Regulated (Transportation) ---\n")
  cat(sprintf("tau = %.4f (SE: %.4f)\n", coef(pool_dot)["treat_post"],
              sqrt(vcov(pool_dot)["treat_post", "treat_post"])))
}

# Safety Sensitive (Manufacturing + Construction)
safety_sensitive <- qwi_border %>%
  filter(industry %in% c("31-33", "23"), in_bandwidth) %>%
  mutate(
    # dist_km already in data,
    treat_post = treated * post
  )

if (nrow(safety_sensitive) > 1000) {
  pool_safety <- feols(
    log_earn_hire ~ treated + post + treat_post + dist_km + treated:dist_km |
      border_pair^quarter + industry,
    data = safety_sensitive,
    cluster = ~border_pair
  )
  cat("\n--- Safety Sensitive (Manufacturing + Construction) ---\n")
  cat(sprintf("tau = %.4f (SE: %.4f)\n", coef(pool_safety)["treat_post"],
              sqrt(vcov(pool_safety)["treat_post", "treat_post"])))
}

# Low Testing Services (Professional + Finance + Information)
low_testing <- qwi_border %>%
  filter(industry %in% c("54", "52", "51"), in_bandwidth) %>%
  mutate(
    # dist_km already in data,
    treat_post = treated * post
  )

if (nrow(low_testing) > 1000) {
  pool_low <- feols(
    log_earn_hire ~ treated + post + treat_post + dist_km + treated:dist_km |
      border_pair^quarter + industry,
    data = low_testing,
    cluster = ~border_pair
  )
  cat("\n--- Low Testing Services ---\n")
  cat(sprintf("tau = %.4f (SE: %.4f)\n", coef(pool_low)["treat_post"],
              sqrt(vcov(pool_low)["treat_post", "treat_post"])))
}

# =============================================================================
# Save Results
# =============================================================================

saveRDS(industry_df, file.path(data_dir, "industry_results.rds"))
saveRDS(category_summary, file.path(data_dir, "category_summary.rds"))

cat("\n=== Industry Analysis Complete ===\n")

# Print final table
cat("\n=== FINAL INDUSTRY RESULTS TABLE ===\n")
industry_df %>%
  select(industry, industry_name, category, tau, se, p_value, p_fdr_all, significant_fdr) %>%
  mutate(
    tau = round(tau, 4),
    se = round(se, 4),
    p_value = round(p_value, 4),
    p_fdr_all = round(p_fdr_all, 4)
  ) %>%
  arrange(category, p_fdr_all) %>%
  print(n = 25)
