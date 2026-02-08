# ==============================================================================
# Paper 188: Moral Foundations Under Digital Pressure
# 08_tables.R - Main tables (7 tables, LaTeX + CSV)
#
# Revision of apep_0052. Ground-up rebuild with Enke framing.
# All tables formatted with kableExtra / booktabs style.
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================\n")
cat("  08_tables.R\n")
cat("========================================\n\n")

# ==============================================================================
# 0. LOAD DATA AND RESULTS
# ==============================================================================

analysis <- arrow::read_parquet("data/analysis_panel.parquet")
cat(sprintf("  Loaded analysis panel: %s rows, %d cols\n",
            format(nrow(analysis), big.mark = ","), ncol(analysis)))

# Ensure output directories
dir.create("tables", showWarnings = FALSE, recursive = TRUE)

# --- Load pre-computed results from analysis scripts ---
# Descriptive results (03_descriptive.R)
if (file.exists("data/descriptive_results.RData")) {
  load("data/descriptive_results.RData")
  cat("  Loaded: descriptive_results.RData\n")
}

# Main DiD results (04_main_analysis.R)
main_results <- if (file.exists("tables/main_results.csv")) {
  read_csv("tables/main_results.csv", show_col_types = FALSE)
} else {
  cat("  WARNING: tables/main_results.csv not found. Table 3/4 will use placeholders.\n")
  NULL
}

# Robustness results (05_robustness.R)
robustness_results <- if (file.exists("tables/robustness_results.csv")) {
  read_csv("tables/robustness_results.csv", show_col_types = FALSE)
} else {
  cat("  WARNING: tables/robustness_results.csv not found. Table 5 will use placeholders.\n")
  NULL
}

# Heterogeneity results (06_heterogeneity.R)
het_partisan <- if (file.exists("tables/het_partisanship.csv")) {
  read_csv("tables/het_partisanship.csv", show_col_types = FALSE)
} else NULL

het_rural <- if (file.exists("tables/het_rurality.csv")) {
  read_csv("tables/het_rurality.csv", show_col_types = FALSE)
} else NULL

het_moral <- if (file.exists("tables/het_moral_orientation.csv")) {
  read_csv("tables/het_moral_orientation.csv", show_col_types = FALSE)
} else NULL

# MDE and equivalence results (04_main_analysis.R or 05_robustness.R)
mde_results <- if (file.exists("tables/mde_results.csv")) {
  read_csv("tables/mde_results.csv", show_col_types = FALSE)
} else NULL

equiv_results <- if (file.exists("tables/equivalence_tests.csv")) {
  read_csv("tables/equivalence_tests.csv", show_col_types = FALSE)
} else NULL

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

#' Format coefficient with significance stars
#' @param coef  Numeric coefficient
#' @param se    Numeric standard error
#' @param pval  Numeric p-value (optional; computed from coef/se if missing)
#' @return Character string like "0.123***"
format_coef <- function(coef, se, pval = NULL) {
  if (is.na(coef) || is.na(se)) return("---")
  if (is.null(pval)) pval <- 2 * pnorm(-abs(coef / se))
  stars <- ifelse(pval < 0.01, "***",
           ifelse(pval < 0.05, "**",
           ifelse(pval < 0.10, "*", "")))
  sprintf("%.4f%s", coef, stars)
}

#' Format SE in parentheses
format_se <- function(se) {
  if (is.na(se)) return("")
  sprintf("(%.4f)", se)
}

#' Format 95% CI
format_ci <- function(coef, se) {
  if (is.na(coef) || is.na(se)) return("[---, ---]")
  lo <- coef - 1.96 * se
  hi <- coef + 1.96 * se
  sprintf("[%.4f, %.4f]", lo, hi)
}

#' Compute sample sizes for footer
get_sample_info <- function(df) {
  list(
    N = nrow(df),
    n_clusters = n_distinct(df$state_fips),
    n_treated = n_distinct(df$place_id[df$treated])
  )
}

sample_info <- get_sample_info(analysis)

# ==============================================================================
# TABLE 1: SUMMARY STATISTICS
# ==============================================================================
cat("\n=== Table 1: Summary Statistics ===\n")

summary_vars <- c("individualizing", "binding", "universalism_index",
                   "moral_intensity", "broadband_rate", "population",
                   "median_income", "pct_college", "pct_white",
                   "median_age", "n_meetings", "rep_share")

# Keep only variables present in data
available_vars <- summary_vars[summary_vars %in% names(analysis)]

# Nicer variable labels
var_labels <- c(
  individualizing    = "Individualizing",
  binding            = "Binding",
  universalism_index = "Universalism Index",
  moral_intensity    = "Moral Intensity",
  broadband_rate     = "Broadband Rate",
  population         = "Population",
  median_income      = "Median Income (\\$)",
  pct_college        = "\\% College",
  pct_white          = "\\% White",
  median_age         = "Median Age",
  n_meetings         = "N Meetings",
  rep_share          = "Republican Vote Share"
)

# Compute statistics
tab1_rows <- lapply(available_vars, function(v) {
  x_all     <- analysis[[v]]
  x_treat   <- analysis[[v]][analysis$treated]
  x_ctrl    <- analysis[[v]][!analysis$treated]

  n_all     <- sum(!is.na(x_all))
  mean_all  <- mean(x_all, na.rm = TRUE)
  sd_all    <- sd(x_all, na.rm = TRUE)
  mean_t    <- mean(x_treat, na.rm = TRUE)
  mean_c    <- mean(x_ctrl, na.rm = TRUE)
  diff_val  <- mean_t - mean_c

  # Welch t-test
  tt <- tryCatch(
    t.test(x_treat, x_ctrl, var.equal = FALSE),
    error = function(e) list(statistic = NA_real_, p.value = NA_real_)
  )
  t_stat <- as.numeric(tt$statistic)

  tibble(
    Variable    = ifelse(v %in% names(var_labels), var_labels[v], v),
    N           = n_all,
    Mean_All    = mean_all,
    SD_All      = sd_all,
    Mean_Treat  = mean_t,
    Mean_Ctrl   = mean_c,
    Difference  = diff_val,
    t_stat      = t_stat
  )
})

tab1 <- bind_rows(tab1_rows)

# CSV version
write_csv(tab1, "tables/table1_summary.csv")
cat("  Saved CSV: tables/table1_summary.csv\n")

# LaTeX version
tab1_latex <- tab1 %>%
  mutate(
    across(c(Mean_All, SD_All, Mean_Treat, Mean_Ctrl, Difference),
           ~sprintf("%.3f", .)),
    N = format(N, big.mark = ","),
    t_stat = sprintf("%.2f", as.numeric(t_stat))
  )

kbl_tab1 <- kbl(tab1_latex,
    format   = "latex",
    booktabs = TRUE,
    escape   = FALSE,
    align    = c("l", "r", "r", "r", "r", "r", "r", "r"),
    col.names = c("Variable", "N", "Mean", "SD",
                  "Mean (Treated)", "Mean (Control)",
                  "Difference", "$t$-stat"),
    caption  = "Summary Statistics: Treated vs.\\ Never-Treated Places",
    label    = "tab:summary") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_header_above(c(" " = 2, "Full Sample" = 2, " " = 4)) %>%
  footnote(
    general = sprintf(
      paste0("Treated places are those that cross the 70\\%% broadband ",
             "subscription threshold during the sample period. ",
             "N = %s place-years across %d states. ",
             "%d treated places. ",
             "Standard errors allow unequal variances (Welch)."),
      format(sample_info$N, big.mark = ","),
      sample_info$n_clusters,
      sample_info$n_treated),
    general_title = "Notes:",
    footnote_as_chunk = TRUE,
    escape = FALSE
  )

writeLines(kbl_tab1, "tables/table1_summary.tex")
cat("  Saved LaTeX: tables/table1_summary.tex\n")


# ==============================================================================
# TABLE 2: TREATMENT COHORT DISTRIBUTION
# ==============================================================================
cat("\n=== Table 2: Treatment Cohort Distribution ===\n")

# Build cohort table from raw data
treated_places <- analysis %>%
  filter(treated) %>%
  distinct(place_id, treat_year)

cohort_dist <- treated_places %>%
  count(treat_year, name = "n_places") %>%
  arrange(treat_year) %>%
  mutate(
    pct_sample = n_places / n_distinct(analysis$place_id) * 100,
    cum_pct    = cumsum(n_places) / n_distinct(analysis$place_id) * 100
  )

# Add never-treated row
n_never <- n_distinct(analysis$place_id[!analysis$treated])
n_total <- n_distinct(analysis$place_id)

tab2 <- bind_rows(
  cohort_dist %>%
    transmute(
      Cohort      = as.character(treat_year),
      N_Places    = n_places,
      Pct_Sample  = pct_sample,
      Cum_Pct     = cum_pct
    ),
  tibble(
    Cohort     = "Never Treated",
    N_Places   = n_never,
    Pct_Sample = n_never / n_total * 100,
    Cum_Pct    = 100
  )
)

write_csv(tab2, "tables/table2_cohorts.csv")
cat("  Saved CSV: tables/table2_cohorts.csv\n")

# LaTeX version
tab2_latex <- tab2 %>%
  mutate(
    N_Places   = format(N_Places, big.mark = ","),
    Pct_Sample = sprintf("%.1f", Pct_Sample),
    Cum_Pct    = sprintf("%.1f", Cum_Pct)
  )

kbl_tab2 <- kbl(tab2_latex,
    format   = "latex",
    booktabs = TRUE,
    escape   = FALSE,
    align    = c("l", "r", "r", "r"),
    col.names = c("Treatment Cohort", "N Places", "\\% of Sample",
                  "Cumulative \\%"),
    caption  = "Treatment Cohort Distribution",
    label    = "tab:cohorts") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(
    general = sprintf(
      paste0("Treatment is defined as first year a place crosses the ",
             "70\\%% broadband subscription threshold. ",
             "Total places: %s across %d states."),
      format(n_total, big.mark = ","),
      sample_info$n_clusters),
    general_title = "Notes:",
    footnote_as_chunk = TRUE,
    escape = FALSE
  )

writeLines(kbl_tab2, "tables/table2_cohorts.tex")
cat("  Saved LaTeX: tables/table2_cohorts.tex\n")


# ==============================================================================
# TABLE 3: MAIN DiD RESULTS (Callaway-Sant'Anna)
# ==============================================================================
cat("\n=== Table 3: Main DiD Results ===\n")

if (!is.null(main_results)) {

  # Expected columns: outcome, specification, att, se, pval, ci_lower, ci_upper, n, n_clusters, n_treated, control_group
  # Reshape into wide format: rows = outcomes, columns = specifications

  outcomes_order <- c("individualizing", "binding", "universalism_index", "log_univ_comm")
  outcome_labels <- c(
    individualizing    = "Individualizing",
    binding            = "Binding",
    universalism_index = "Universalism Index",
    log_univ_comm      = "Log Ratio"
  )

  # Identify specification columns
  specs <- unique(main_results$specification)
  spec_labels <- c(
    "no_controls"   = "(1) No Controls",
    "with_controls" = "(2) With Controls",
    "anticipation"  = "(3) Anticipation = 1"
  )
  # Fallback: use whatever spec names exist
  if (!all(specs %in% names(spec_labels))) {
    spec_labels <- setNames(paste0("(", seq_along(specs), ") ", specs), specs)
  }

  # Build table rows
  tab3_rows <- list()
  for (out in outcomes_order) {
    if (!out %in% main_results$outcome) next
    coef_row <- c(Outcome = outcome_labels[out])
    se_row   <- c(Outcome = "")
    ci_row   <- c(Outcome = "")

    for (sp in specs) {
      row_data <- main_results %>%
        filter(outcome == out, specification == sp)
      if (nrow(row_data) == 0) {
        coef_row[sp] <- "---"
        se_row[sp]   <- ""
        ci_row[sp]   <- ""
      } else {
        r <- row_data[1, ]
        p <- ifelse("pval" %in% names(r), r$pval,
             ifelse("p_value" %in% names(r), r$p_value,
                    2 * pnorm(-abs(r$att / r$se))))
        coef_row[sp] <- format_coef(r$att, r$se, p)
        se_row[sp]   <- format_se(r$se)
        # 95% CI
        ci_lo <- ifelse("ci_lower" %in% names(r), r$ci_lower, r$att - 1.96 * r$se)
        ci_hi <- ifelse("ci_upper" %in% names(r), r$ci_upper, r$att + 1.96 * r$se)
        ci_row[sp] <- sprintf("[%.4f, %.4f]", ci_lo, ci_hi)
      }
    }
    tab3_rows <- c(tab3_rows, list(coef_row), list(se_row), list(ci_row))
  }

  tab3_df <- bind_rows(lapply(tab3_rows, function(x) as_tibble_row(x)))

  # Footer info from first available row
  footer_row <- main_results[1, ]
  footer_n        <- ifelse("n" %in% names(footer_row), footer_row$n, sample_info$N)
  footer_clusters <- ifelse("n_clusters" %in% names(footer_row), footer_row$n_clusters, sample_info$n_clusters)
  footer_treated  <- ifelse("n_treated" %in% names(footer_row), footer_row$n_treated, sample_info$n_treated)
  footer_cg       <- ifelse("control_group" %in% names(footer_row), footer_row$control_group, "Never-treated")

  # Save CSV
  write_csv(tab3_df, "tables/table3_main_did.csv")

  # LaTeX
  col_names <- c("Outcome", names(spec_labels[specs]))
  if (length(col_names) != ncol(tab3_df)) {
    col_names <- names(tab3_df)
  }

  kbl_tab3 <- kbl(tab3_df,
      format   = "latex",
      booktabs = TRUE,
      escape   = FALSE,
      align    = c("l", rep("c", ncol(tab3_df) - 1)),
      col.names = col_names,
      caption  = "Main Difference-in-Differences Results (Callaway--Sant'Anna)",
      label    = "tab:main_did") %>%
    kable_styling(latex_options = c("hold_position", "scale_down")) %>%
    footnote(
      general = sprintf(
        paste0("Callaway and Sant'Anna (2021) staggered DiD estimator. ",
               "Treatment: first year broadband rate $\\\\geq$ 70\\%%. ",
               "N = %s. Clusters (states) = %s. Treated places = %s. ",
               "Control group: %s. ",
               "Standard errors clustered at state level in parentheses. ",
               "95\\%% confidence intervals in brackets. ",
               "$^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.10$."),
        format(as.integer(footer_n), big.mark = ","),
        footer_clusters, footer_treated, footer_cg),
      general_title = "Notes:",
      footnote_as_chunk = TRUE,
      escape = FALSE
    )

  writeLines(kbl_tab3, "tables/table3_main_did.tex")
  cat("  Saved: tables/table3_main_did.tex, tables/table3_main_did.csv\n")

} else {
  cat("  SKIPPED: main_results.csv not found.\n")
}


# ==============================================================================
# TABLE 4: INDIVIDUAL FOUNDATION RESULTS
# ==============================================================================
cat("\n=== Table 4: Individual Foundation Results ===\n")

if (!is.null(main_results)) {

  foundation_outcomes <- c("care_p", "fairness_p", "loyalty_p",
                           "authority_p", "sanctity_p")
  foundation_labels <- c(
    care_p      = "Care",
    fairness_p  = "Fairness",
    loyalty_p   = "Loyalty",
    authority_p = "Authority",
    sanctity_p  = "Sanctity"
  )

  # Use the preferred specification (with controls, or first available)
  pref_spec <- intersect(c("with_controls", "no_controls"), unique(main_results$specification))[1]
  if (is.na(pref_spec)) pref_spec <- unique(main_results$specification)[1]

  tab4_rows <- lapply(foundation_outcomes, function(out) {
    r <- main_results %>%
      filter(outcome == out, specification == pref_spec)
    if (nrow(r) == 0) {
      return(tibble(
        Foundation = foundation_labels[out],
        ATT = NA_real_, SE = NA_real_,
        CI_95 = "---", p_value = NA_real_
      ))
    }
    r <- r[1, ]
    p <- ifelse("pval" %in% names(r), r$pval,
         ifelse("p_value" %in% names(r), r$p_value,
                2 * pnorm(-abs(r$att / r$se))))
    ci_lo <- ifelse("ci_lower" %in% names(r), r$ci_lower, r$att - 1.96 * r$se)
    ci_hi <- ifelse("ci_upper" %in% names(r), r$ci_upper, r$att + 1.96 * r$se)
    tibble(
      Foundation = foundation_labels[out],
      ATT        = r$att,
      SE         = r$se,
      CI_95      = sprintf("[%.4f, %.4f]", ci_lo, ci_hi),
      p_value    = as.numeric(p)
    )
  })

  tab4 <- bind_rows(tab4_rows)
  write_csv(tab4, "tables/table4_foundations.csv")

  # LaTeX formatting
  tab4_latex <- tab4 %>%
    mutate(
      ATT     = ifelse(is.na(ATT), "---", sprintf("%.4f", ATT)),
      SE      = ifelse(is.na(SE), "---", sprintf("%.4f", SE)),
      p_value = ifelse(is.na(p_value), "---", sprintf("%.3f", p_value))
    )

  kbl_tab4 <- kbl(tab4_latex,
      format   = "latex",
      booktabs = TRUE,
      escape   = FALSE,
      align    = c("l", "r", "r", "c", "r"),
      col.names = c("Foundation", "ATT", "SE", "95\\% CI", "$p$-value"),
      caption  = "Individual Moral Foundation Results (Callaway--Sant'Anna)",
      label    = "tab:foundations") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    footnote(
      general = sprintf(
        paste0("Callaway and Sant'Anna (2021) estimator with doubly-robust ",
               "controls. Specification: %s. ",
               "N = %s. Clusters (states) = %d. Treated places = %d. ",
               "Standard errors clustered at state level. ",
               "$^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.10$."),
        gsub("_", " ", pref_spec),
        format(sample_info$N, big.mark = ","),
        sample_info$n_clusters,
        sample_info$n_treated),
      general_title = "Notes:",
      footnote_as_chunk = TRUE,
      escape = FALSE
    )

  writeLines(kbl_tab4, "tables/table4_foundations.tex")
  cat("  Saved: tables/table4_foundations.tex, tables/table4_foundations.csv\n")

} else {
  cat("  SKIPPED: main_results.csv not found.\n")
}


# ==============================================================================
# TABLE 5: ROBUSTNESS BATTERY
# ==============================================================================
cat("\n=== Table 5: Robustness Battery ===\n")

if (!is.null(robustness_results)) {

  # Expected columns: specification, outcome, att, se, pval/p_value, n
  # We focus on universalism_index as the headline outcome

  target_outcome <- "universalism_index"

  # Desired row order (match whatever names appear in the data)
  spec_order <- c("baseline_cs", "alt_60", "alt_65", "alt_75", "alt_80",
                   "continuous", "sun_abraham", "acs_1yr")
  spec_display <- c(
    baseline_cs = "Baseline (C-S, 70\\%)",
    alt_60      = "Alt.\\ Threshold: 60\\%",
    alt_65      = "Alt.\\ Threshold: 65\\%",
    alt_75      = "Alt.\\ Threshold: 75\\%",
    alt_80      = "Alt.\\ Threshold: 80\\%",
    continuous  = "Continuous Treatment",
    sun_abraham = "Sun--Abraham (2021)",
    acs_1yr     = "1-Year ACS Sample"
  )

  tab5_raw <- robustness_results %>%
    filter(
      outcome == target_outcome |
      tolower(outcome) == target_outcome
    )

  # Match specification order
  tab5_raw <- tab5_raw %>%
    mutate(
      spec_clean = specification,
      spec_label = ifelse(specification %in% names(spec_display),
                          spec_display[specification],
                          gsub("_", " ", specification))
    )

  # Reorder
  known <- tab5_raw %>% filter(specification %in% spec_order)
  unknown <- tab5_raw %>% filter(!specification %in% spec_order)
  if (nrow(known) > 0) {
    known <- known %>%
      mutate(spec_rank = match(specification, spec_order)) %>%
      arrange(spec_rank) %>%
      select(-spec_rank)
  }
  tab5_ordered <- bind_rows(known, unknown)

  tab5 <- tab5_ordered %>%
    mutate(
      p = ifelse("pval" %in% names(.), pval,
          ifelse("p_value" %in% names(.), p_value,
                 2 * pnorm(-abs(att / se)))),
      n_display = ifelse("n" %in% names(.), n, sample_info$N)
    ) %>%
    transmute(
      Specification = spec_label,
      ATT           = att,
      SE            = se,
      p_value       = as.numeric(p),
      N             = as.integer(n_display)
    )

  write_csv(tab5, "tables/table5_robustness.csv")

  # LaTeX formatting
  tab5_latex <- tab5 %>%
    mutate(
      ATT_str = mapply(format_coef, ATT, SE, p_value),
      SE_str  = sprintf("(%.4f)", SE),
      p_value = sprintf("%.3f", p_value),
      N       = format(N, big.mark = ",")
    ) %>%
    select(Specification, ATT_str, SE_str, p_value, N) %>%
    rename(ATT = ATT_str, SE = SE_str)

  kbl_tab5 <- kbl(tab5_latex,
      format   = "latex",
      booktabs = TRUE,
      escape   = FALSE,
      align    = c("l", "r", "r", "r", "r"),
      col.names = c("Specification", "ATT", "SE", "$p$-value", "N"),
      caption  = "Robustness Battery: Effect on Universalism Index",
      label    = "tab:robustness") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    footnote(
      general = paste0(
        "Outcome: universalism index. Each row is a separate specification. ",
        "Baseline is Callaway--Sant'Anna with 70\\% broadband threshold ",
        "and never-treated control group. ",
        "Standard errors clustered at state level (in parentheses). ",
        "$^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.10$."),
      general_title = "Notes:",
      footnote_as_chunk = TRUE,
      escape = FALSE
    )

  writeLines(kbl_tab5, "tables/table5_robustness.tex")
  cat("  Saved: tables/table5_robustness.tex, tables/table5_robustness.csv\n")

} else {
  cat("  SKIPPED: robustness_results.csv not found.\n")
}


# ==============================================================================
# TABLE 6: HETEROGENEITY RESULTS
# ==============================================================================
cat("\n=== Table 6: Heterogeneity Results ===\n")

# Combine all heterogeneity sources
het_rows <- list()

# Full sample baseline (from main results if available)
if (!is.null(main_results)) {
  baseline <- main_results %>%
    filter(outcome == "universalism_index",
           specification %in% c("with_controls", "no_controls")) %>%
    slice(1)
  if (nrow(baseline) > 0) {
    bp <- ifelse("pval" %in% names(baseline), baseline$pval,
          ifelse("p_value" %in% names(baseline), baseline$p_value,
                 2 * pnorm(-abs(baseline$att / baseline$se))))
    het_rows[["Full Sample"]] <- tibble(
      Subgroup = "Full Sample",
      ATT      = baseline$att,
      SE       = baseline$se,
      N        = ifelse("n" %in% names(baseline), baseline$n, sample_info$N),
      p_value  = as.numeric(bp)
    )
  }
}

# Partisanship heterogeneity
if (!is.null(het_partisan)) {
  for (i in seq_len(nrow(het_partisan))) {
    r <- het_partisan[i, ]
    lbl <- ifelse("subgroup" %in% names(r), as.character(r$subgroup),
           ifelse("group" %in% names(r), as.character(r$group), paste("Partisan", i)))
    p <- ifelse("pval" %in% names(r), r$pval,
         ifelse("p_value" %in% names(r), r$p_value,
                2 * pnorm(-abs(r$att / r$se))))
    het_rows[[lbl]] <- tibble(
      Subgroup = lbl,
      ATT      = r$att,
      SE       = r$se,
      N        = ifelse("n" %in% names(r), r$n, NA_integer_),
      p_value  = as.numeric(p)
    )
  }
}

# Rurality heterogeneity
if (!is.null(het_rural)) {
  for (i in seq_len(nrow(het_rural))) {
    r <- het_rural[i, ]
    lbl <- ifelse("subgroup" %in% names(r), as.character(r$subgroup),
           ifelse("group" %in% names(r), as.character(r$group), paste("Rural", i)))
    p <- ifelse("pval" %in% names(r), r$pval,
         ifelse("p_value" %in% names(r), r$p_value,
                2 * pnorm(-abs(r$att / r$se))))
    het_rows[[lbl]] <- tibble(
      Subgroup = lbl,
      ATT      = r$att,
      SE       = r$se,
      N        = ifelse("n" %in% names(r), r$n, NA_integer_),
      p_value  = as.numeric(p)
    )
  }
}

# Moral orientation heterogeneity
if (!is.null(het_moral)) {
  for (i in seq_len(nrow(het_moral))) {
    r <- het_moral[i, ]
    lbl <- ifelse("subgroup" %in% names(r), as.character(r$subgroup),
           ifelse("group" %in% names(r), as.character(r$group), paste("Moral", i)))
    p <- ifelse("pval" %in% names(r), r$pval,
         ifelse("p_value" %in% names(r), r$p_value,
                2 * pnorm(-abs(r$att / r$se))))
    het_rows[[lbl]] <- tibble(
      Subgroup = lbl,
      ATT      = r$att,
      SE       = r$se,
      N        = ifelse("n" %in% names(r), r$n, NA_integer_),
      p_value  = as.numeric(p)
    )
  }
}

if (length(het_rows) > 0) {
  tab6 <- bind_rows(het_rows)
  write_csv(tab6, "tables/table6_heterogeneity.csv")

  # LaTeX
  tab6_latex <- tab6 %>%
    mutate(
      ATT_str = mapply(format_coef, ATT, SE, p_value),
      SE_str  = sprintf("(%.4f)", SE),
      p_value = sprintf("%.3f", p_value),
      N       = ifelse(is.na(N), "---", format(as.integer(N), big.mark = ","))
    ) %>%
    select(Subgroup, ATT_str, SE_str, N, p_value) %>%
    rename(ATT = ATT_str, SE = SE_str)

  # Determine group boundaries for panels
  # Panel A: Partisanship (Full Sample + partisan rows)
  # Panel B: Rurality
  # Panel C: Moral Orientation
  kbl_tab6 <- kbl(tab6_latex,
      format   = "latex",
      booktabs = TRUE,
      escape   = FALSE,
      align    = c("l", "r", "r", "r", "r"),
      col.names = c("Subgroup", "ATT", "SE", "N", "$p$-value"),
      caption  = "Heterogeneity in Treatment Effects: Universalism Index",
      label    = "tab:heterogeneity") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    footnote(
      general = paste0(
        "Outcome: universalism index. Each row estimates the Callaway--Sant'Anna ",
        "ATT separately for the indicated subgroup. ",
        "Partisanship defined by county-level Republican vote share in the most ",
        "recent pre-treatment presidential election. ",
        "Rurality based on USDA Rural-Urban Continuum Codes (Metro = RUCC 1--3). ",
        "Moral orientation based on pre-treatment universalism index ",
        "(above/below median). ",
        "Standard errors clustered at state level. ",
        "$^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.10$."),
      general_title = "Notes:",
      footnote_as_chunk = TRUE,
      escape = FALSE
    )

  writeLines(kbl_tab6, "tables/table6_heterogeneity.tex")
  cat("  Saved: tables/table6_heterogeneity.tex, tables/table6_heterogeneity.csv\n")

} else {
  cat("  SKIPPED: No heterogeneity result files found.\n")
}


# ==============================================================================
# TABLE 7: MDE AND EQUIVALENCE TESTS
# ==============================================================================
cat("\n=== Table 7: MDE and Equivalence Tests ===\n")

has_mde   <- !is.null(mde_results)
has_equiv <- !is.null(equiv_results)

if (has_mde || has_equiv) {

  # --- Panel A: MDE at 80% Power ---
  if (has_mde) {
    panelA <- mde_results %>%
      transmute(
        Outcome    = ifelse("outcome" %in% names(.), outcome, "---"),
        MDE_raw    = ifelse("mde" %in% names(.), mde,
                    ifelse("mde_raw" %in% names(.), mde_raw, NA_real_)),
        MDE_sd     = ifelse("mde_sd" %in% names(.), mde_sd, NA_real_),
        Outcome_SD = ifelse("outcome_sd" %in% names(.), outcome_sd, NA_real_),
        Power      = ifelse("power" %in% names(.), power, 0.80)
      )
  } else {
    # Compute MDE from main results using actual SEs
    if (!is.null(main_results)) {
      mde_outcomes <- c("individualizing", "binding", "universalism_index",
                        "log_univ_comm")
      panelA <- main_results %>%
        filter(outcome %in% mde_outcomes,
               specification %in% c("with_controls", "no_controls")) %>%
        group_by(outcome) %>%
        slice(1) %>%
        ungroup() %>%
        mutate(
          outcome_sd = sapply(outcome, function(o) {
            sd(analysis[[o]], na.rm = TRUE)
          }),
          mde_raw = se * (qnorm(0.975) + qnorm(0.80)),
          mde_sd  = mde_raw / outcome_sd
        ) %>%
        transmute(
          Outcome    = outcome,
          MDE_raw    = mde_raw,
          MDE_sd     = mde_sd,
          Outcome_SD = outcome_sd,
          Power      = 0.80
        )
    } else {
      panelA <- tibble()
    }
  }

  # --- Panel B: Equivalence Test Results ---
  if (has_equiv) {
    panelB <- equiv_results
  } else {
    panelB <- tibble()
  }

  # Build combined table as list of character vectors
  tab7_parts <- list()

  # Panel A header
  tab7_parts <- c(tab7_parts, list(
    tibble(
      Col1 = "\\textbf{Panel A: Minimum Detectable Effects (80\\% Power)}",
      Col2 = "", Col3 = "", Col4 = "", Col5 = ""
    )
  ))

  if (nrow(panelA) > 0) {
    outcome_display <- c(
      individualizing    = "Individualizing",
      binding            = "Binding",
      universalism_index = "Universalism Index",
      log_univ_comm      = "Log Ratio"
    )
    for (i in seq_len(nrow(panelA))) {
      r <- panelA[i, ]
      out_label <- ifelse(r$Outcome %in% names(outcome_display),
                          outcome_display[r$Outcome], r$Outcome)
      tab7_parts <- c(tab7_parts, list(tibble(
        Col1 = paste0("\\quad ", out_label),
        Col2 = sprintf("%.4f", r$MDE_raw),
        Col3 = sprintf("%.3f SD", r$MDE_sd),
        Col4 = sprintf("%.4f", r$Outcome_SD),
        Col5 = ""
      )))
    }
  }

  # Panel B header
  tab7_parts <- c(tab7_parts, list(
    tibble(
      Col1 = "\\textbf{Panel B: Equivalence Tests (TOST)}",
      Col2 = "", Col3 = "", Col4 = "", Col5 = ""
    )
  ))

  if (nrow(panelB) > 0) {
    for (i in seq_len(nrow(panelB))) {
      r <- panelB[i, ]
      bound_val <- ifelse("bound" %in% names(r), r$bound,
                   ifelse("delta" %in% names(r), r$delta, NA_real_))
      outcome_val <- ifelse("outcome" %in% names(r), r$outcome, "universalism_index")
      reject_val <- ifelse("reject" %in% names(r), r$reject,
                    ifelse("rejected" %in% names(r), r$rejected, NA))
      p_upper <- ifelse("p_upper" %in% names(r), r$p_upper,
                 ifelse("pval" %in% names(r), r$pval, NA_real_))
      tab7_parts <- c(tab7_parts, list(tibble(
        Col1 = sprintf("\\quad $\\delta = %.2f$ SD", bound_val),
        Col2 = ifelse(!is.na(reject_val) && reject_val, "Reject $H_0$", "Fail to reject"),
        Col3 = ifelse(!is.na(p_upper), sprintf("$p = %.3f$", p_upper), "---"),
        Col4 = "",
        Col5 = ""
      )))
    }
  } else {
    # Generate equivalence tests from data if not pre-computed
    if (!is.null(main_results)) {
      baseline <- main_results %>%
        filter(outcome == "universalism_index",
               specification %in% c("with_controls", "no_controls")) %>%
        slice(1)
      if (nrow(baseline) > 0) {
        att_val <- baseline$att
        se_val  <- baseline$se
        sd_y    <- sd(analysis$universalism_index, na.rm = TRUE)
        for (delta_sd in c(0.05, 0.10, 0.15)) {
          delta_raw <- delta_sd * sd_y
          # TOST: reject if both one-sided tests reject
          t_upper <- (att_val - delta_raw) / se_val
          t_lower <- (att_val + delta_raw) / se_val
          p_upper <- pnorm(t_upper)  # test H0: ATT >= delta
          p_lower <- 1 - pnorm(t_lower)  # test H0: ATT <= -delta
          p_tost  <- max(p_upper, p_lower)
          reject  <- p_tost < 0.05
          tab7_parts <- c(tab7_parts, list(tibble(
            Col1 = sprintf("\\quad $\\delta = %.2f$ SD (%.4f)", delta_sd, delta_raw),
            Col2 = ifelse(reject, "Reject $H_0$", "Fail to reject"),
            Col3 = sprintf("$p_{\\text{TOST}} = %.3f$", p_tost),
            Col4 = "",
            Col5 = ""
          )))
        }
      }
    }
  }

  # Panel C: Comparison to Enke (2020) effect sizes
  tab7_parts <- c(tab7_parts, list(
    tibble(
      Col1 = "\\textbf{Panel C: Comparison to Enke (2020) Effect Sizes}",
      Col2 = "", Col3 = "", Col4 = "", Col5 = ""
    ),
    tibble(
      Col1 = "\\quad Enke (2020): Internet $\\rightarrow$ Universalism (cross-sectional)",
      Col2 = "0.15--0.25 SD",
      Col3 = "",
      Col4 = "",
      Col5 = ""
    ),
    tibble(
      Col1 = "\\quad Enke (2020): Urbanization $\\rightarrow$ Universalism",
      Col2 = "0.20--0.35 SD",
      Col3 = "",
      Col4 = "",
      Col5 = ""
    )
  ))

  if (nrow(panelA) > 0) {
    mde_univ <- panelA %>% filter(grepl("universalism", Outcome, ignore.case = TRUE))
    if (nrow(mde_univ) > 0) {
      tab7_parts <- c(tab7_parts, list(tibble(
        Col1 = sprintf("\\quad Our MDE (80\\%% power): %.3f SD", mde_univ$MDE_sd[1]),
        Col2 = ifelse(mde_univ$MDE_sd[1] > 0.25,
                       "Cannot detect Enke-sized effects",
                       "Can detect Enke-sized effects"),
        Col3 = "",
        Col4 = "",
        Col5 = ""
      )))
    }
  }

  tab7_df <- bind_rows(tab7_parts)

  write_csv(tab7_df, "tables/table7_mde_equivalence.csv")

  kbl_tab7 <- kbl(tab7_df,
      format   = "latex",
      booktabs = TRUE,
      escape   = FALSE,
      align    = c("l", "c", "c", "c", "c"),
      col.names = c("", "", "", "", ""),
      caption  = "Minimum Detectable Effects and Equivalence Tests",
      label    = "tab:mde_equivalence") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    footnote(
      general = paste0(
        "Panel A reports the minimum detectable effect (MDE) at 80\\% power ",
        "given our sample size, treatment variation, and state-clustered SEs. ",
        "Panel B reports Two One-Sided Tests (TOST) for equivalence at the ",
        "indicated bounds in SD units of the outcome. ",
        "Panel C compares our detectable effects to cross-sectional estimates ",
        "from Enke (2020, \\\\textit{JPE}). ",
        "N = %s. Clusters (states) = %d."),
      general_title = "Notes:",
      footnote_as_chunk = TRUE,
      escape = FALSE
    )

  writeLines(kbl_tab7, "tables/table7_mde_equivalence.tex")
  cat("  Saved: tables/table7_mde_equivalence.tex, tables/table7_mde_equivalence.csv\n")

} else {
  # Fallback: compute everything from scratch
  cat("  No pre-computed MDE/equivalence files. Computing from analysis panel.\n")

  # We need main_results for SEs; if not available, compute simple TWFE
  if (!is.null(main_results)) {

    mde_outcomes <- c("individualizing", "binding", "universalism_index",
                      "log_univ_comm")
    outcome_display <- c(
      individualizing    = "Individualizing",
      binding            = "Binding",
      universalism_index = "Universalism Index",
      log_univ_comm      = "Log Ratio"
    )

    panelA_rows <- list()
    for (out in mde_outcomes) {
      r <- main_results %>%
        filter(outcome == out) %>%
        slice(1)
      if (nrow(r) == 0) next
      sd_y <- sd(analysis[[out]], na.rm = TRUE)
      mde_raw <- r$se * (qnorm(0.975) + qnorm(0.80))
      mde_sd <- mde_raw / sd_y
      panelA_rows <- c(panelA_rows, list(tibble(
        Outcome    = outcome_display[out],
        MDE_raw    = mde_raw,
        MDE_sd     = mde_sd,
        Outcome_SD = sd_y
      )))
    }
    panelA <- bind_rows(panelA_rows)

    # Equivalence tests
    baseline <- main_results %>%
      filter(outcome == "universalism_index") %>%
      slice(1)
    equiv_rows <- list()
    if (nrow(baseline) > 0) {
      sd_y <- sd(analysis$universalism_index, na.rm = TRUE)
      for (delta_sd in c(0.05, 0.10, 0.15)) {
        delta_raw <- delta_sd * sd_y
        t_upper <- (baseline$att - delta_raw) / baseline$se
        t_lower <- (baseline$att + delta_raw) / baseline$se
        p_tost <- max(pnorm(t_upper), 1 - pnorm(t_lower))
        equiv_rows <- c(equiv_rows, list(tibble(
          Bound_SD  = delta_sd,
          Bound_Raw = delta_raw,
          Reject    = p_tost < 0.05,
          p_TOST    = p_tost
        )))
      }
    }
    panelB <- bind_rows(equiv_rows)

    # Build final table
    tab7_parts <- list()

    # Panel A
    tab7_parts <- c(tab7_parts, list(tibble(
      Col1 = "\\textbf{Panel A: Minimum Detectable Effects (80\\% Power)}",
      Col2 = "", Col3 = "", Col4 = ""
    )))
    for (i in seq_len(nrow(panelA))) {
      r <- panelA[i, ]
      tab7_parts <- c(tab7_parts, list(tibble(
        Col1 = paste0("\\quad ", r$Outcome),
        Col2 = sprintf("%.4f", r$MDE_raw),
        Col3 = sprintf("%.3f SD", r$MDE_sd),
        Col4 = sprintf("SD$_y$ = %.4f", r$Outcome_SD)
      )))
    }

    # Panel B
    tab7_parts <- c(tab7_parts, list(tibble(
      Col1 = "\\textbf{Panel B: Equivalence Tests (TOST)}",
      Col2 = "", Col3 = "", Col4 = ""
    )))
    for (i in seq_len(nrow(panelB))) {
      r <- panelB[i, ]
      tab7_parts <- c(tab7_parts, list(tibble(
        Col1 = sprintf("\\quad $\\delta = %.2f$ SD (%.4f)", r$Bound_SD, r$Bound_Raw),
        Col2 = ifelse(r$Reject, "Reject $H_0$", "Fail to reject"),
        Col3 = sprintf("$p_{\\text{TOST}} = %.3f$", r$p_TOST),
        Col4 = ""
      )))
    }

    # Panel C
    tab7_parts <- c(tab7_parts, list(
      tibble(
        Col1 = "\\textbf{Panel C: Comparison to Enke (2020) Effect Sizes}",
        Col2 = "", Col3 = "", Col4 = ""
      ),
      tibble(
        Col1 = "\\quad Enke (2020): Internet $\\rightarrow$ Universalism",
        Col2 = "0.15--0.25 SD", Col3 = "", Col4 = ""
      ),
      tibble(
        Col1 = "\\quad Enke (2020): Urbanization $\\rightarrow$ Universalism",
        Col2 = "0.20--0.35 SD", Col3 = "", Col4 = ""
      )
    ))

    mde_univ <- panelA %>% filter(grepl("Universalism", Outcome))
    if (nrow(mde_univ) > 0) {
      tab7_parts <- c(tab7_parts, list(tibble(
        Col1 = sprintf("\\quad Our MDE: %.3f SD", mde_univ$MDE_sd[1]),
        Col2 = ifelse(mde_univ$MDE_sd[1] > 0.25,
                       "Cannot detect Enke-sized effects",
                       "Can detect Enke-sized effects"),
        Col3 = "", Col4 = ""
      )))
    }

    tab7_df <- bind_rows(tab7_parts)
    write_csv(tab7_df, "tables/table7_mde_equivalence.csv")

    kbl_tab7 <- kbl(tab7_df,
        format   = "latex",
        booktabs = TRUE,
        escape   = FALSE,
        align    = c("l", "c", "c", "c"),
        col.names = c("", "", "", ""),
        caption  = "Minimum Detectable Effects and Equivalence Tests",
        label    = "tab:mde_equivalence") %>%
      kable_styling(latex_options = c("hold_position")) %>%
      footnote(
        general = sprintf(
          paste0("Panel A: MDE at 80\\%% power = SE $\\times$ ($z_{0.975}$ + $z_{0.80}$). ",
                 "Panel B: Two One-Sided Tests at indicated bounds. ",
                 "Panel C: Enke (2020, \\\\textit{JPE}) cross-sectional estimates. ",
                 "N = %s. Clusters (states) = %d."),
          format(sample_info$N, big.mark = ","),
          sample_info$n_clusters),
        general_title = "Notes:",
        footnote_as_chunk = TRUE,
        escape = FALSE
      )

    writeLines(kbl_tab7, "tables/table7_mde_equivalence.tex")
    cat("  Saved: tables/table7_mde_equivalence.tex, tables/table7_mde_equivalence.csv\n")

  } else {
    cat("  SKIPPED: No main results or MDE files available.\n")
  }
}


# ==============================================================================
# SUMMARY
# ==============================================================================
cat("\n========================================\n")
cat("  08_tables.R COMPLETE\n")
cat("========================================\n")
cat("  Tables generated:\n")
for (f in list.files("tables", pattern = "^table[0-9].*\\.(tex|csv)$")) {
  cat(sprintf("    %s\n", f))
}
cat("========================================\n")
