# ==============================================================================
# 06_tables.R
# State Minimum Wage Increases and Young Adult Household Formation
# Purpose: Generate LaTeX tables for the paper
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================================\n")
cat("  06_tables.R: Generating LaTeX tables\n")
cat("========================================================\n\n")

# ==============================================================================
# SECTION 1: Load data and results
# ==============================================================================

cat("--- Loading data and model objects ---\n")

panel <- read.csv(file.path(DATA_DIR, "analysis_panel.csv"),
                  stringsAsFactors = FALSE)

# Load model objects with safe fallback
load_safe <- function(path) {
  tryCatch(readRDS(path), error = function(e) {
    cat("  Warning: could not load", basename(path), "\n")
    NULL
  })
}

cs_out       <- load_safe(file.path(DATA_DIR, "cs_out.rds"))
es           <- load_safe(file.path(DATA_DIR, "cs_event_study.rds"))
att_overall  <- load_safe(file.path(DATA_DIR, "cs_overall_att.rds"))
att_group    <- load_safe(file.path(DATA_DIR, "cs_group_att.rds"))
twfe         <- load_safe(file.path(DATA_DIR, "twfe_model.rds"))
sa           <- load_safe(file.path(DATA_DIR, "sa_model.rds"))
cs_cov       <- load_safe(file.path(DATA_DIR, "cs_cov_out.rds"))
att_cov      <- load_safe(file.path(DATA_DIR, "cs_cov_att.rds"))
att_indep    <- load_safe(file.path(DATA_DIR, "cs_indep_att.rds"))
robustness   <- load_safe(file.path(DATA_DIR, "robustness_results.rds"))
region_res   <- load_safe(file.path(DATA_DIR, "region_heterogeneity.rds"))
dose_linear  <- load_safe(file.path(DATA_DIR, "dose_linear.rds"))
dose_quad    <- load_safe(file.path(DATA_DIR, "dose_quad.rds"))

cat("  All available objects loaded.\n\n")

# Helper: format number with significance stars
fmt_coef <- function(est, se, digits = 3) {
  if (is.na(est) || is.na(se) || se == 0) return("---")
  tstat <- abs(est / se)
  stars <- ""
  if (tstat > 2.576) stars <- "***"
  else if (tstat > 1.960) stars <- "**"
  else if (tstat > 1.645) stars <- "*"
  paste0(sprintf(paste0("%.", digits, "f"), est), stars)
}

fmt_se <- function(se, digits = 3) {
  if (is.na(se)) return("")
  paste0("(", sprintf(paste0("%.", digits, "f"), se), ")")
}

# ==============================================================================
# TABLE 1: Summary statistics
# ==============================================================================

cat("--- Table 1: Summary statistics ---\n")

# Compute summary stats for key variables
summary_vars <- list(
  # Outcomes
  list(name = "\\% Living with parents",     var = "pct_with_parents",   panel = "A"),
  list(name = "\\% Living independently",    var = "pct_independent",    panel = "A"),
  list(name = "\\% Living alone",            var = "pct_alone",          panel = "A"),
  list(name = "\\% With spouse",             var = "pct_with_spouse",    panel = "A"),
  list(name = "\\% With partner",            var = "pct_with_partner",   panel = "A"),
  # Treatment
  list(name = "State minimum wage (\\$)",    var = "state_mw",           panel = "B"),
  list(name = "Federal minimum wage (\\$)",  var = "federal_mw",         panel = "B"),
  list(name = "MW gap (\\$)",                var = "mw_gap",             panel = "B"),
  list(name = "Treated (binary)",            var = "treated",            panel = "B"),
  # Controls
  list(name = "State population",            var = "population",         panel = "C"),
  list(name = "Median gross rent (\\$)",     var = "median_rent",        panel = "C")
)

# Build table rows
n_obs    <- nrow(panel)
n_states <- length(unique(panel$state_fips))
n_years  <- length(unique(panel$year))

tab1_lines <- c(
  "\\begin{table}[H]",
  "\\centering",
  "\\caption{Summary Statistics}",
  "\\label{tab:summary}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lccccc}",
  "\\toprule",
  "Variable & Mean & SD & Min & Max & N \\\\",
  "\\midrule"
)

current_panel <- ""
for (sv in summary_vars) {
  x <- panel[[sv$var]]
  x <- x[!is.na(x)]

  # Panel header
  if (sv$panel != current_panel) {
    if (current_panel != "") {
      tab1_lines <- c(tab1_lines, "\\addlinespace")
    }
    panel_label <- switch(sv$panel,
                          "A" = "\\textit{Panel A: Outcome Variables}",
                          "B" = "\\textit{Panel B: Treatment Variables}",
                          "C" = "\\textit{Panel C: Control Variables}")
    tab1_lines <- c(tab1_lines, paste0(panel_label, " & & & & & \\\\"))
    current_panel <- sv$panel
  }

  # Format large numbers
  if (sv$var == "population") {
    row <- sprintf("%s & %s & %s & %s & %s & %d \\\\",
                   sv$name,
                   format(round(mean(x)), big.mark = ","),
                   format(round(sd(x)), big.mark = ","),
                   format(round(min(x)), big.mark = ","),
                   format(round(max(x)), big.mark = ","),
                   length(x))
  } else {
    row <- sprintf("%s & %.2f & %.2f & %.2f & %.2f & %d \\\\",
                   sv$name,
                   mean(x), sd(x), min(x), max(x), length(x))
  }
  tab1_lines <- c(tab1_lines, row)
}

tab1_lines <- c(tab1_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  sprintf("\\item \\textit{Notes:} State-year panel, %d---%d. %d states (including DC), %d years. N = %d state-year observations.",
          min(panel$year), max(panel$year), n_states, n_years, n_obs),
  "Outcome variables expressed as percentages of the total 18--34 population.",
  "Treatment defined as state minimum wage exceeding the federal floor by $\\geq$\\$1.00.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tab1_lines, file.path(TAB_DIR, "tab_summary.tex"))
cat("  Saved: tab_summary.tex\n\n")

# ==============================================================================
# TABLE 2: Main regression results
# ==============================================================================

cat("--- Table 2: Main results ---\n")

# Extract key results
twfe_est  <- if (!is.null(twfe)) coef(twfe)["treated"] else NA
twfe_se   <- if (!is.null(twfe)) se(twfe)["treated"] else NA
twfe_n    <- if (!is.null(twfe)) nobs(twfe) else NA
twfe_r2   <- if (!is.null(twfe)) r2(twfe, type = "r2") else NA

cs_est    <- if (!is.null(att_overall)) att_overall$overall.att else NA
cs_se     <- if (!is.null(att_overall)) att_overall$overall.se else NA

sa_est    <- NA
sa_se     <- NA
sa_n      <- NA
sa_r2     <- NA
if (!is.null(sa)) {
  sa_coefs <- coef(sa)
  sa_names <- names(sa_coefs)
  post_coefs <- sa_coefs[grepl("::", sa_names)]
  if (length(post_coefs) > 0) {
    sa_est <- mean(post_coefs)
    # Approximate SE from individual SEs
    sa_ses <- se(sa)[grepl("::", names(se(sa)))]
    sa_se  <- sqrt(mean(sa_ses^2))
  }
  sa_n  <- nobs(sa)
  sa_r2 <- r2(sa, type = "r2")
}

tab2_lines <- c(
  "\\begin{table}[H]",
  "\\centering",
  "\\caption{Effect of Minimum Wage Increases on Young Adult Parental Co-residence}",
  "\\label{tab:main_results}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  " & (1) & (2) & (3) \\\\",
  " & TWFE & CS-DiD & Sun--Abraham \\\\",
  "\\midrule",
  sprintf("Treatment effect & %s & %s & %s \\\\",
          fmt_coef(twfe_est, twfe_se),
          fmt_coef(cs_est, cs_se),
          fmt_coef(sa_est, sa_se)),
  sprintf(" & %s & %s & %s \\\\",
          fmt_se(twfe_se),
          fmt_se(cs_se),
          fmt_se(sa_se)),
  "\\addlinespace",
  sprintf("Observations & %s & %s & %s \\\\",
          ifelse(!is.na(twfe_n), format(twfe_n, big.mark = ","), "---"),
          format(nrow(panel), big.mark = ","),
          ifelse(!is.na(sa_n), format(sa_n, big.mark = ","), "---")),
  sprintf("$R^2$ & %s & --- & %s \\\\",
          ifelse(!is.na(twfe_r2), sprintf("%.3f", twfe_r2), "---"),
          ifelse(!is.na(sa_r2), sprintf("%.3f", sa_r2), "---")),
  "State FE & Yes & --- & Yes \\\\",
  "Year FE & Yes & --- & Yes \\\\",
  "Control group & --- & Never-treated & --- \\\\",
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Dependent variable: percent of 18--34 year-olds living with parents.",
  "Column (1) reports two-way fixed effects estimates.",
  "Column (2) reports the overall ATT from Callaway \\& Sant'Anna (2021) using never-treated states as the control group.",
  "Column (3) reports the interaction-weighted estimator of Sun \\& Abraham (2021).",
  "Standard errors clustered at the state level in parentheses.",
  "* $p<0.10$, ** $p<0.05$, *** $p<0.01$.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tab2_lines, file.path(TAB_DIR, "tab_main_results.tex"))
cat("  Saved: tab_main_results.tex\n\n")

# ==============================================================================
# TABLE 3: Robustness results
# ==============================================================================

cat("--- Table 3: Robustness ---\n")

# Build rows from robustness results
rob_rows <- list()

# Baseline
rob_rows[[1]] <- list(
  spec = "Baseline (MW gap $\\geq$ \\$1.00, never-treated)",
  est  = cs_est, se = cs_se
)

# Alternative thresholds
if (!is.null(robustness)) {
  for (nm in grep("^threshold_", names(robustness), value = TRUE)) {
    r <- robustness[[nm]]
    # Skip $1.00 threshold — it duplicates the baseline row
    if (abs(r$threshold - 1.00) < 0.01) next
    rob_rows[[length(rob_rows) + 1]] <- list(
      spec = sprintf("MW gap $\\geq$ \\$%.2f", r$threshold),
      est  = r$att, se = r$se
    )
  }

  # Not-yet-treated
  if (!is.null(robustness$not_yet_treated)) {
    r <- robustness$not_yet_treated$att_obj
    rob_rows[[length(rob_rows) + 1]] <- list(
      spec = "Not-yet-treated control group",
      est = r$overall.att, se = r$overall.se
    )
  }

  # Drop 2021 (post-COVID)
  if (!is.null(robustness$no_2021)) {
    r <- robustness$no_2021$att_obj
    rob_rows[[length(rob_rows) + 1]] <- list(
      spec = "Excluding 2021",
      est = r$overall.att, se = r$overall.se
    )
  }

  # Pre-pandemic only (2015-2019)
  if (!is.null(robustness$prepandemic)) {
    r <- robustness$prepandemic$att_obj
    rob_rows[[length(rob_rows) + 1]] <- list(
      spec = "Pre-pandemic only (2015--2019)",
      est = r$overall.att, se = r$overall.se
    )
  }

  # Placebo
  if (!is.null(robustness$placebo)) {
    r <- robustness$placebo$att_obj
    rob_rows[[length(rob_rows) + 1]] <- list(
      spec = "Placebo: \\% other arrangements",
      est = r$overall.att, se = r$overall.se
    )
  }

  # Dose-response
  if (!is.null(dose_linear)) {
    rob_rows[[length(rob_rows) + 1]] <- list(
      spec = "Continuous MW gap (linear, TWFE)",
      est = coef(dose_linear)["mw_gap_continuous"],
      se  = se(dose_linear)["mw_gap_continuous"]
    )
  }
}

# Alternative outcome: pct_independent
if (!is.null(att_indep)) {
  rob_rows[[length(rob_rows) + 1]] <- list(
    spec = "Alternative DV: \\% independent",
    est = att_indep$overall.att, se = att_indep$overall.se
  )
}

tab3_lines <- c(
  "\\begin{table}[H]",
  "\\centering",
  "\\caption{Robustness of Minimum Wage Effects on Parental Co-residence}",
  "\\label{tab:robustness}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lcc}",
  "\\toprule",
  "Specification & ATT & SE \\\\",
  "\\midrule"
)

for (r in rob_rows) {
  tab3_lines <- c(tab3_lines,
    sprintf("%s & %s & %s \\\\",
            r$spec,
            fmt_coef(r$est, r$se),
            fmt_se(r$se)))
}

tab3_lines <- c(tab3_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Each row reports the overall ATT from a separate CS-DiD estimation unless otherwise noted.",
  "The baseline uses the \\$1.00 threshold (MW gap $\\geq$ \\$1.00) with never-treated states as controls, as reported in Table~\\ref{tab:main_results}.",
  "Alternative threshold rows redefine treatment cohorts using the specified gap.",
  "The placebo test uses the share in other arrangements (group quarters, etc.) as the outcome.",
  "The baseline sample is 357 state-year observations (51 jurisdictions $\\times$ 7 years: 2015--2019, 2021--2022; 2020 not released).",
  "``Excluding 2021'' drops the first post-pandemic year ($N = 306$). ``Pre-pandemic only'' retains 2015--2019 ($N = 255$).",
  "Standard errors (in parentheses) are clustered at the state level.",
  "* $p<0.10$, ** $p<0.05$, *** $p<0.01$.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tab3_lines, file.path(TAB_DIR, "tab_robustness.tex"))
cat("  Saved: tab_robustness.tex\n\n")

# ==============================================================================
# TABLE 4: Heterogeneity by region
# ==============================================================================

cat("--- Table 4: Heterogeneity ---\n")

tab4_lines <- c(
  "\\begin{table}[H]",
  "\\centering",
  "\\caption{Heterogeneity in Treatment Effects by Census Region}",
  "\\label{tab:heterogeneity}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lccccc}",
  "\\toprule",
  "Region & ATT & SE & 95\\% CI & Treated States & Never-Treated \\\\",
  "\\midrule"
)

# Overall
if (!is.null(att_overall)) {
  n_tr <- length(unique(panel$state_fips[panel$first_treat > 0]))
  n_nt <- length(unique(panel$state_fips[panel$first_treat == 0]))
  ci_str <- sprintf("[%.3f, %.3f]",
                    att_overall$overall.att - 1.96 * att_overall$overall.se,
                    att_overall$overall.att + 1.96 * att_overall$overall.se)
  tab4_lines <- c(tab4_lines,
    sprintf("\\textbf{Overall} & %s & %s & %s & %d & %d \\\\",
            fmt_coef(att_overall$overall.att, att_overall$overall.se),
            fmt_se(att_overall$overall.se),
            ci_str, n_tr, n_nt),
    "\\addlinespace"
  )
}

# By region
if (!is.null(region_res) && length(region_res) > 0) {
  for (reg in sort(names(region_res))) {
    r <- region_res[[reg]]
    att_r <- r$att_obj
    ci_str <- sprintf("[%.3f, %.3f]",
                      att_r$overall.att - 1.96 * att_r$overall.se,
                      att_r$overall.att + 1.96 * att_r$overall.se)
    tab4_lines <- c(tab4_lines,
      sprintf("%s & %s & %s & %s & %d & %d \\\\",
              reg,
              fmt_coef(att_r$overall.att, att_r$overall.se),
              fmt_se(att_r$overall.se),
              ci_str,
              r$n_treated,
              r$n_never))
  }
}

tab4_lines <- c(tab4_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Each row reports the overall ATT from a separate CS-DiD estimation on the regional subsample.",
  "The overall row uses the full national sample.",
  "Census regions: Northeast (CT, ME, MA, NH, NJ, NY, PA, RI, VT),",
  "Midwest (IL, IN, IA, KS, MI, MN, MO, NE, ND, OH, SD, WI),",
  "South (AL, AR, DE, DC, FL, GA, KY, LA, MD, MS, NC, OK, SC, TN, TX, VA, WV),",
  "West (AK, AZ, CA, CO, HI, ID, MT, NV, NM, OR, UT, WA, WY).",
  "Standard errors clustered at the state level.",
  "* $p<0.10$, ** $p<0.05$, *** $p<0.01$.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tab4_lines, file.path(TAB_DIR, "tab_heterogeneity.tex"))
cat("  Saved: tab_heterogeneity.tex\n\n")

# ==============================================================================
# TABLE 5 (BONUS): Event study coefficients
# ==============================================================================

cat("--- Table 5: Event study coefficients ---\n")

if (!is.null(es)) {
  tab5_lines <- c(
    "\\begin{table}[H]",
    "\\centering",
    "\\caption{Event Study Estimates: Callaway--Sant'Anna Dynamic Effects}",
    "\\label{tab:event_study}",
    "\\begin{threeparttable}",
    "\\begin{tabular}{lccc}",
    "\\toprule",
    "Event Time & ATT & SE & 95\\% CI \\\\",
    "\\midrule",
    "\\textit{Pre-treatment} & & & \\\\"
  )

  # Check if e=-1 is already in the data
  has_ref_period <- -1 %in% es$egt

  for (i in seq_along(es$egt)) {
    e <- es$egt[i]
    att_e <- es$att.egt[i]
    se_e  <- es$se.egt[i]

    # Add reference period row before post-treatment section (only if not already in data)
    if (i > 1 && es$egt[i-1] < 0 && e >= 0 && !has_ref_period) {
      tab5_lines <- c(tab5_lines,
        "$e = -1$ & (ref.) & --- & --- \\\\",
        "\\addlinespace",
        "\\textit{Post-treatment} & & & \\\\"
      )
    }

    # Handle NA values or reference period (e=-1)
    if (is.na(att_e) || is.na(se_e)) {
      tab5_lines <- c(tab5_lines,
        sprintf("$e = %+d$ & (ref.) & --- & --- \\\\", e))
      # Add post-treatment header after the reference period row
      if (e == -1 && i < length(es$egt) && es$egt[i+1] >= 0) {
        tab5_lines <- c(tab5_lines,
          "\\addlinespace",
          "\\textit{Post-treatment} & & & \\\\"
        )
      }
      next
    }

    # Add post-treatment separator if transitioning from pre to post without ref period
    if (i > 1 && es$egt[i-1] < -1 && e >= 0 && has_ref_period) {
      # This handles the unlikely case where e=-1 is in data but has values
    }

    ci_str <- sprintf("[%.3f, %.3f]",
                      att_e - 1.96 * se_e,
                      att_e + 1.96 * se_e)

    tab5_lines <- c(tab5_lines,
      sprintf("$e = %+d$ & %s & %s & %s \\\\",
              e,
              fmt_coef(att_e, se_e),
              fmt_se(se_e),
              ci_str))
  }

  # Add overall ATT at bottom
  tab5_lines <- c(tab5_lines,
    "\\addlinespace",
    "\\midrule",
    sprintf("Overall ATT & %s & %s & [%.3f, %.3f] \\\\",
            fmt_coef(att_overall$overall.att, att_overall$overall.se),
            fmt_se(att_overall$overall.se),
            att_overall$overall.att - 1.96 * att_overall$overall.se,
            att_overall$overall.att + 1.96 * att_overall$overall.se),
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} Event study estimates from Callaway \\& Sant'Anna (2021).",
    "Event time $e$ measures years relative to treatment adoption.",
    "The reference period is $e = -1$.",
    "Standard errors based on clustered bootstrap.",
    "* $p<0.10$, ** $p<0.05$, *** $p<0.01$.",
    "\\end{tablenotes}",
    "\\end{threeparttable}",
    "\\end{table}"
  )

  writeLines(tab5_lines, file.path(TAB_DIR, "tab_event_study.tex"))
  cat("  Saved: tab_event_study.tex\n\n")
}

# ==============================================================================
# TABLE 6 (BONUS): TWFE and Sun-Abraham via etable
# ==============================================================================

cat("--- Table 6: TWFE / Sun-Abraham via etable ---\n")

if (!is.null(twfe) && !is.null(sa)) {
  models <- list(twfe, sa)
  model_names <- c("TWFE", "Sun-Abraham")

  etable_output <- tryCatch({
    etable(
      models,
      headers = model_names,
      style.tex = style.tex("aer"),
      fitstat = ~ n + r2,
      se.below = TRUE,
      signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.10),
      tex = TRUE,
      file = file.path(TAB_DIR, "tab_twfe_sa.tex"),
      replace = TRUE,
      title = "Two-Way Fixed Effects and Sun--Abraham Estimates",
      label = "tab:twfe_sa"
    )
    TRUE
  }, error = function(e) {
    cat("  Note: etable output failed:", conditionMessage(e), "\n")
    FALSE
  })

  if (etable_output) {
    cat("  Saved: tab_twfe_sa.tex\n\n")
  }
} else {
  cat("  TWFE or SA model not available; skipping etable.\n\n")
}

# ==============================================================================
# Summary
# ==============================================================================

cat("========================================================\n")
cat("  TABLES GENERATED\n")
cat("========================================================\n\n")

tabs_generated <- list.files(TAB_DIR, pattern = "\\.tex$")
for (f in tabs_generated) {
  cat("  ", f, "\n")
}

cat("\n========================================================\n")
cat("  06_tables.R completed successfully.\n")
cat("========================================================\n")
