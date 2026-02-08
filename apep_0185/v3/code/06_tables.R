################################################################################
# 06_tables.R
# Social Network Spillovers of Minimum Wage
#
# Input:  data/analysis_panel.rds, data/main_results.rds
# Output: tables/tab*.tex
################################################################################

source("00_packages.R")

cat("=== Generating Tables ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

panel <- readRDS("../data/analysis_panel.rds")
results <- readRDS("../data/main_results.rds")
robustness <- readRDS("../data/robustness_results.rds")
state_mw <- readRDS("../data/state_mw_panel.rds")

cat("Data loaded.\n")

# Check for QWI outcomes
has_qwi <- "log_emp" %in% names(panel)

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("\nTable 1: Summary statistics...\n")

# Panel summary
panel_summary <- panel %>%
  summarise(
    `Counties` = n_distinct(county_fips),
    `States` = n_distinct(state_fips),
    `Quarters` = n_distinct(yearq),
    `Observations` = format(n(), big.mark = ",")
  )

# Exposure summary
exposure_summary <- panel %>%
  summarise(
    `Network Exposure Mean` = sprintf("%.3f", mean(social_exposure, na.rm = TRUE)),
    `Network Exposure SD` = sprintf("%.3f", sd(social_exposure, na.rm = TRUE)),
    `Geographic Exposure Mean` = sprintf("%.3f", mean(geo_exposure, na.rm = TRUE)),
    `Geographic Exposure SD` = sprintf("%.3f", sd(geo_exposure, na.rm = TRUE)),
    `Correlation (Network, Geographic)` = sprintf("%.3f",
      cor(social_exposure, geo_exposure, use = "complete.obs"))
  )

# Minimum wage summary
mw_summary <- state_mw %>%
  filter(min_wage > 7.25) %>%
  summarise(
    `States with MW > Federal` = n_distinct(state_fips),
    `Min State MW` = sprintf("$%.2f", min(min_wage)),
    `Max State MW` = sprintf("$%.2f", max(min_wage))
  )

# Combine into table
tab1_data <- tibble(
  Statistic = c(
    "Panel Structure", "", "",
    "Counties", "States", "Quarters", "Observations",
    "", "Exposure Variables", "",
    "Network Exposure (Mean)", "Network Exposure (SD)",
    "Geographic Exposure (Mean)", "Geographic Exposure (SD)",
    "Correlation (Network, Geographic)",
    "", "Minimum Wage Variation", "",
    "States with MW > Federal", "Minimum State MW", "Maximum State MW"
  ),
  Value = c(
    "", "", "",
    as.character(panel_summary$Counties),
    as.character(panel_summary$States),
    as.character(panel_summary$Quarters),
    panel_summary$Observations,
    "", "", "",
    exposure_summary$`Network Exposure Mean`,
    exposure_summary$`Network Exposure SD`,
    exposure_summary$`Geographic Exposure Mean`,
    exposure_summary$`Geographic Exposure SD`,
    exposure_summary$`Correlation (Network, Geographic)`,
    "", "", "",
    as.character(mw_summary$`States with MW > Federal`),
    mw_summary$`Min State MW`,
    mw_summary$`Max State MW`
  )
)

tab1_latex <- tab1_data %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    col.names = c("", ""),
    caption = "Summary Statistics",
    label = "sumstats"
  ) %>%
  kable_styling(latex_options = "hold_position") %>%
  add_footnote(
    paste0("Notes: Network exposure is the SCI-weighted average of log minimum wages ",
           "in other states. Geographic exposure uses inverse-distance weights. ",
           "Sample period: 2010-2023."),
    notation = "none"
  )

writeLines(tab1_latex, "../tables/tab1_sumstats.tex")
cat("  Saved tab1_sumstats.tex\n")

# ============================================================================
# Table 2: Main Results
# ============================================================================

cat("\nTable 2: Main results...\n")

# Extract coefficients from three-tiered estimation
tier1_coef <- coef(results$tier1_naive)[1]
tier1_se <- se(results$tier1_naive)[1]
tier2_coef <- coef(results$tier2_shiftshare)[1]
tier2_se <- se(results$tier2_shiftshare)[1]
tier3_social <- coef(results$tier3_horserace)["social_exposure"]
tier3_social_se <- se(results$tier3_horserace)["social_exposure"]
tier3_geo <- coef(results$tier3_horserace)["geo_exposure"]
tier3_geo_se <- se(results$tier3_horserace)["geo_exposure"]

# Stars function
stars <- function(pval) {
  if (is.na(pval)) return("")
  if (pval < 0.01) return("***")
  if (pval < 0.05) return("**")
  if (pval < 0.1) return("*")
  return("")
}

tab2_data <- tibble(
  ` ` = c(
    "Network Exposure (SCI)", "",
    "Geographic Exposure", "",
    "", "County FE", "Time FE", "State $\\times$ Time FE",
    "Observations", "R$^2$"
  ),
  `(1) Naive` = c(
    paste0(sprintf("%.4f", tier1_coef), stars(fixest::pvalue(results$tier1_naive)[1])),
    sprintf("(%.4f)", tier1_se),
    "", "",
    "", "Yes", "Yes", "No",
    format(nrow(panel), big.mark = ","),
    sprintf("%.3f", fixest::r2(results$tier1_naive)["r2"])
  ),
  `(2) Shift-Share` = c(
    paste0(sprintf("%.4f", tier2_coef), stars(fixest::pvalue(results$tier2_shiftshare)[1])),
    sprintf("(%.4f)", tier2_se),
    "", "",
    "", "Yes", "No", "Yes",
    format(nrow(panel), big.mark = ","),
    sprintf("%.3f", fixest::r2(results$tier2_shiftshare)["r2"])
  ),
  `(3) Horse Race` = c(
    paste0(sprintf("%.4f", tier3_social), stars(fixest::pvalue(results$tier3_horserace)["social_exposure"])),
    sprintf("(%.4f)", tier3_social_se),
    paste0(sprintf("%.4f", tier3_geo), stars(fixest::pvalue(results$tier3_horserace)["geo_exposure"])),
    sprintf("(%.4f)", tier3_geo_se),
    "", "Yes", "No", "Yes",
    format(nrow(panel), big.mark = ","),
    sprintf("%.3f", fixest::r2(results$tier3_horserace)["r2"])
  )
)

tab2_latex <- tab2_data %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    escape = FALSE,
    caption = "Main Results: Effect of Network Exposure on Employment",
    label = "mainresults",
    align = c("l", "c", "c", "c")
  ) %>%
  kable_styling(latex_options = "hold_position") %>%
  add_footnote(
    paste0("Notes: Dependent variable is log employment. Network exposure is ",
           "SCI-weighted average of log minimum wages in other states. ",
           "Geographic exposure uses inverse-distance weights. ",
           "Standard errors clustered at state level in parentheses. ",
           "*** p<0.01, ** p<0.05, * p<0.1."),
    notation = "none"
  )

writeLines(tab2_latex, "../tables/tab2_main.tex")
cat("  Saved tab2_main.tex\n")

# ============================================================================
# Table 3: Industry Heterogeneity
# ============================================================================

cat("\nTable 3: Industry heterogeneity...\n")

if (!is.null(results$high_bite) && !is.null(results$low_bite)) {
  tab3_data <- tibble(
    ` ` = c(
      "Network Exposure", "",
      "", "Industry", "Observations", "R$^2$"
    ),
    `(1) High-Bite` = c(
      paste0(sprintf("%.4f", coef(results$high_bite)[1]),
             stars(fixest::pvalue(results$high_bite)[1])),
      sprintf("(%.4f)", se(results$high_bite)[1]),
      "", "Retail, Food Service",
      format(sum(panel$industry_type == "High Bite", na.rm = TRUE), big.mark = ","),
      sprintf("%.3f", fixest::r2(results$high_bite)["r2"])
    ),
    `(2) Low-Bite (Placebo)` = c(
      paste0(sprintf("%.4f", coef(results$low_bite)[1]),
             stars(fixest::pvalue(results$low_bite)[1])),
      sprintf("(%.4f)", se(results$low_bite)[1]),
      "", "Finance, Prof. Services",
      format(sum(panel$industry_type == "Low Bite", na.rm = TRUE), big.mark = ","),
      sprintf("%.3f", fixest::r2(results$low_bite)["r2"])
    )
  )

  tab3_latex <- tab3_data %>%
    kable(
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,
      caption = "Industry Heterogeneity: High-Bite vs. Low-Bite Industries",
      label = "industry",
      align = c("l", "c", "c")
    ) %>%
    kable_styling(latex_options = "hold_position") %>%
    add_footnote(
      paste0("Notes: High-bite industries (NAICS 44-45, 72) have many minimum wage workers. ",
             "Low-bite industries (NAICS 52, 54) have few minimum wage workers and serve as placebo. ",
             "All specifications include county and state $\\times$ time fixed effects. ",
             "*** p<0.01, ** p<0.05, * p<0.1."),
      notation = "none"
    )

  writeLines(tab3_latex, "../tables/tab3_industry.tex")
  cat("  Saved tab3_industry.tex\n")
}

# ============================================================================
# Table 4: Robustness Checks
# ============================================================================

cat("\nTable 4: Robustness checks...\n")

# Build robustness table
robustness_rows <- list()

# Main result
robustness_rows[[1]] <- c("Main Specification",
                          sprintf("%.4f", coef(results$tier2_shiftshare)[1]),
                          sprintf("%.4f", se(results$tier2_shiftshare)[1]),
                          sprintf("%.3f", fixest::pvalue(results$tier2_shiftshare)[1]))

# Geographic only
robustness_rows[[2]] <- c("Geographic Exposure Only",
                          sprintf("%.4f", coef(robustness$geo_only)[1]),
                          sprintf("%.4f", se(robustness$geo_only)[1]),
                          sprintf("%.3f", fixest::pvalue(robustness$geo_only)[1]))

# Orthogonal social
robustness_rows[[3]] <- c("Orthogonalized Network (Residual)",
                          sprintf("%.4f", coef(robustness$ortho_only)[1]),
                          sprintf("%.4f", se(robustness$ortho_only)[1]),
                          sprintf("%.3f", fixest::pvalue(robustness$ortho_only)[1]))

# Lagged exposure
if (!is.null(robustness$lag1)) {
  robustness_rows[[4]] <- c("1-Quarter Lagged Exposure",
                            sprintf("%.4f", coef(robustness$lag1)[1]),
                            sprintf("%.4f", se(robustness$lag1)[1]),
                            sprintf("%.3f", fixest::pvalue(robustness$lag1)[1]))
}

# Pre-COVID
if (!is.null(robustness$pre_covid)) {
  robustness_rows[[5]] <- c("Pre-2020 Sample",
                            sprintf("%.4f", coef(robustness$pre_covid)[1]),
                            sprintf("%.4f", se(robustness$pre_covid)[1]),
                            sprintf("%.3f", fixest::pvalue(robustness$pre_covid)[1]))
}

# RI p-value
robustness_rows[[6]] <- c("Randomization Inference",
                          sprintf("%.4f", coef(results$tier2_shiftshare)[1]),
                          "--",
                          sprintf("%.3f", robustness$ri_pval))

tab4_data <- do.call(rbind, robustness_rows)
tab4_data <- as.data.frame(tab4_data, stringsAsFactors = FALSE)
names(tab4_data) <- c("Specification", "Coefficient", "Std. Error", "p-value")

tab4_latex <- tab4_data %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Robustness Checks",
    label = "robustness",
    align = c("l", "c", "c", "c")
  ) %>%
  kable_styling(latex_options = "hold_position") %>%
  pack_rows("Alternative Specifications", 1, 3) %>%
  pack_rows("Dynamic Effects", 4, 5) %>%
  pack_rows("Inference", 6, 6) %>%
  add_footnote(
    paste0("Notes: All specifications include county and state $\\times$ time fixed effects. ",
           "Randomization inference based on 500 permutations of exposure. ",
           "Standard errors clustered at state level."),
    notation = "none"
  )

writeLines(tab4_latex, "../tables/tab4_robustness.tex")
cat("  Saved tab4_robustness.tex\n")

# ============================================================================
# Table 5: Leave-One-State-Out
# ============================================================================

cat("\nTable 5: Leave-one-state-out...\n")

if (!is.null(robustness$loso_results) && length(robustness$loso_results) > 0) {
  loso_rows <- lapply(names(robustness$loso_results), function(st) {
    state_name <- case_when(
      st == "06" ~ "California",
      st == "36" ~ "New York",
      st == "53" ~ "Washington",
      st == "25" ~ "Massachusetts",
      st == "12" ~ "Florida",
      TRUE ~ st
    )
    c(paste("Excluding", state_name),
      sprintf("%.4f", robustness$loso_results[[st]]$coef),
      sprintf("%.4f", robustness$loso_results[[st]]$se))
  })

  # Add full sample
  loso_rows <- c(
    list(c("Full Sample",
           sprintf("%.4f", coef(results$tier2_shiftshare)[1]),
           sprintf("%.4f", se(results$tier2_shiftshare)[1]))),
    loso_rows
  )

  tab5_data <- do.call(rbind, loso_rows)
  tab5_data <- as.data.frame(tab5_data, stringsAsFactors = FALSE)
  names(tab5_data) <- c("Sample", "Coefficient", "Std. Error")

  tab5_latex <- tab5_data %>%
    kable(
      format = "latex",
      booktabs = TRUE,
      caption = "Leave-One-State-Out Robustness",
      label = "loso",
      align = c("l", "c", "c")
    ) %>%
    kable_styling(latex_options = "hold_position") %>%
    add_footnote(
      paste0("Notes: Each row excludes one major minimum wage state from the sample. ",
             "Results should be stable if no single state drives the findings. ",
             "Standard errors clustered at state level."),
      notation = "none"
    )

  writeLines(tab5_latex, "../tables/tab5_loso.tex")
  cat("  Saved tab5_loso.tex\n")
}

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Tables Complete ===\n")
cat("Generated tables in ../tables/\n")
